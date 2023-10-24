package gioui

import (
	"image"
	"image/color"

	"gioui.org/io/clipboard"
	"gioui.org/io/key"
	"gioui.org/io/pointer"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/op/clip"
	"gioui.org/op/paint"
	"gioui.org/unit"
	"gioui.org/widget/material"
	"github.com/vsariola/sointu/tracker"
)

type DragList struct {
	TrackerList  tracker.List
	HoverItem    int
	List         *layout.List
	ScrollBar    *ScrollBar
	drag         bool
	dragID       pointer.ID
	tags         []bool
	swapped      bool
	focused      bool
	requestFocus bool
	mainTag      bool
}

type FilledDragListStyle struct {
	dragList       *DragList
	HoverColor     color.NRGBA
	SelectedColor  color.NRGBA
	CursorColor    color.NRGBA
	ScrollBarWidth unit.Dp
	element, bg    func(gtx C, i int) D
}

func NewDragList(model tracker.List, axis layout.Axis) *DragList {
	return &DragList{TrackerList: model, List: &layout.List{Axis: axis}, HoverItem: -1, ScrollBar: &ScrollBar{Axis: axis}}
}

func FilledDragList(th *material.Theme, dragList *DragList, element, bg func(gtx C, i int) D) FilledDragListStyle {
	return FilledDragListStyle{
		dragList:       dragList,
		element:        element,
		bg:             bg,
		HoverColor:     dragListHoverColor,
		SelectedColor:  dragListSelectedColor,
		CursorColor:    cursorColor,
		ScrollBarWidth: unit.Dp(10),
	}
}

func (d *DragList) Focus() {
	d.requestFocus = true
}

func (d *DragList) Focused() bool {
	return d.focused
}

func (s FilledDragListStyle) LayoutScrollBar(gtx C) D {
	return s.dragList.ScrollBar.Layout(gtx, s.ScrollBarWidth, s.dragList.TrackerList.Count(), &s.dragList.List.Position)
}

func (s FilledDragListStyle) Layout(gtx C) D {
	swap := 0

	defer op.Offset(image.Point{}).Push(gtx.Ops).Pop()
	defer clip.Rect(image.Rect(0, 0, gtx.Constraints.Max.X, gtx.Constraints.Max.Y)).Push(gtx.Ops).Pop()
	keys := key.Set("↑|↓|Ctrl-↑|Ctrl-↓|Shift-↑|Shift-↓|⇞|⇟|Ctrl-⇞|Ctrl-⇟|Ctrl-A|Ctrl-C|Ctrl-X|Ctrl-V|⌦|Ctrl-⌫")
	if s.dragList.List.Axis == layout.Horizontal {
		keys = key.Set("←|→|Ctrl-←|Ctrl-→|Shift-←|Shift-→|Home|End|Ctrl-Home|Ctrl-End|Ctrl-A|Ctrl-C|Ctrl-X|Ctrl-V|⌦|Ctrl-⌫")
	}
	key.InputOp{Tag: &s.dragList.mainTag, Keys: keys}.Add(gtx.Ops)

	if s.dragList.List.Axis == layout.Horizontal {
		gtx.Constraints.Min.X = gtx.Constraints.Max.X
	} else {
		gtx.Constraints.Min.Y = gtx.Constraints.Max.Y
	}

	if s.dragList.requestFocus {
		s.dragList.requestFocus = false
		key.FocusOp{Tag: &s.dragList.mainTag}.Add(gtx.Ops)
	}

	for _, ke := range gtx.Events(&s.dragList.mainTag) {
		switch ke := ke.(type) {
		case key.FocusEvent:
			s.dragList.focused = ke.Focus
			if !s.dragList.focused {
				s.dragList.TrackerList.SetSelected2(s.dragList.TrackerList.Selected())
			}
		case key.Event:
			if !s.dragList.focused || ke.State != key.Press {
				break
			}
			s.dragList.command(gtx, ke)
		case clipboard.Event:
			s.dragList.TrackerList.PasteElements([]byte(ke.Text))
		}
		op.InvalidateOp{}.Add(gtx.Ops)
	}

	_, isMutable := s.dragList.TrackerList.ListData.(tracker.MutableListData)

	listElem := func(gtx C, index int) D {
		for len(s.dragList.tags) <= index {
			s.dragList.tags = append(s.dragList.tags, false)
		}
		cursorBg := func(gtx C) D {
			var color color.NRGBA
			if s.dragList.TrackerList.Selected() == index {
				if s.dragList.focused {
					color = s.CursorColor
				} else {
					color = s.SelectedColor
				}
			} else if between(s.dragList.TrackerList.Selected(), index, s.dragList.TrackerList.Selected2()) {
				color = s.SelectedColor
			} else if s.dragList.HoverItem == index {
				color = s.HoverColor
			}
			paint.FillShape(gtx.Ops, color, clip.Rect{Max: image.Pt(gtx.Constraints.Min.X, gtx.Constraints.Min.Y)}.Op())

			for _, ev := range gtx.Events(&s.dragList.tags[index]) {
				e, ok := ev.(pointer.Event)
				if !ok {
					continue
				}
				switch e.Type {
				case pointer.Enter:
					s.dragList.HoverItem = index
				case pointer.Leave:
					if s.dragList.HoverItem == index {
						s.dragList.HoverItem = -1
					}
				case pointer.Press:
					if s.dragList.drag {
						break
					}
					s.dragList.TrackerList.SetSelected(index)
					if !e.Modifiers.Contain(key.ModShift) {
						s.dragList.TrackerList.SetSelected2(index)
					}
					key.FocusOp{Tag: &s.dragList.mainTag}.Add(gtx.Ops)
				}
			}
			rect := image.Rect(0, 0, gtx.Constraints.Min.X, gtx.Constraints.Min.Y)
			area := clip.Rect(rect).Push(gtx.Ops)
			pointer.InputOp{Tag: &s.dragList.tags[index],
				Types: pointer.Press | pointer.Enter | pointer.Leave,
			}.Add(gtx.Ops)
			area.Pop()
			if index == s.dragList.TrackerList.Selected() && isMutable {
				for _, ev := range gtx.Events(&s.dragList.focused) {
					e, ok := ev.(pointer.Event)
					if !ok {
						continue
					}
					switch e.Type {
					case pointer.Press:
						s.dragList.dragID = e.PointerID
						s.dragList.drag = true
					case pointer.Drag:
						if s.dragList.dragID != e.PointerID {
							break
						}
						if s.dragList.List.Axis == layout.Horizontal {
							if e.Position.X < 0 {
								swap = -1
							}
							if e.Position.X > float32(gtx.Constraints.Min.X) {
								swap = 1
							}
						} else {
							if e.Position.Y < 0 {
								swap = -1
							}
							if e.Position.Y > float32(gtx.Constraints.Min.Y) {
								swap = 1
							}
						}
					case pointer.Release:
						fallthrough
					case pointer.Cancel:
						s.dragList.drag = false
					}
				}
				area := clip.Rect(rect).Push(gtx.Ops)
				pointer.InputOp{Tag: &s.dragList.focused,
					Types: pointer.Drag | pointer.Press | pointer.Release,
					Grab:  s.dragList.drag,
				}.Add(gtx.Ops)
				pointer.CursorGrab.Add(gtx.Ops)
				area.Pop()
			}
			return layout.Dimensions{Size: gtx.Constraints.Min}
		}
		macro := op.Record(gtx.Ops)
		dims := s.element(gtx, index)
		call := macro.Stop()
		gtx.Constraints.Min = dims.Size
		if s.bg != nil {
			s.bg(gtx, index)
		}
		cursorBg(gtx)
		call.Add(gtx.Ops)
		if s.dragList.List.Axis == layout.Horizontal {
			dims.Size.Y = gtx.Constraints.Max.Y
		} else {
			dims.Size.X = gtx.Constraints.Max.X
		}
		return dims
	}
	count := s.dragList.TrackerList.Count()
	if count < 1 {
		count = 1 // draw at least one empty element to get the correct size
	}
	dims := s.dragList.List.Layout(gtx, count, listElem)
	if !s.dragList.swapped && swap != 0 {
		if s.dragList.TrackerList.MoveElements(swap) {
			op.InvalidateOp{}.Add(gtx.Ops)
		}
		s.dragList.swapped = true
	} else {
		s.dragList.swapped = false
	}
	return dims
}

func (e *DragList) command(gtx layout.Context, k key.Event) {
	if k.Modifiers.Contain(key.ModShortcut) {
		switch k.Name {
		case "V":
			clipboard.ReadOp{Tag: &e.mainTag}.Add(gtx.Ops)
			return
		case "C", "X":
			data, ok := e.TrackerList.CopyElements()
			if ok && (k.Name == "C" || e.TrackerList.DeleteElements(false)) {
				clipboard.WriteOp{Text: string(data)}.Add(gtx.Ops)
			}
			return
		case "A":
			e.TrackerList.SetSelected(0)
			e.TrackerList.SetSelected2(e.TrackerList.Count() - 1)
			return
		}
	}
	delta := 0
	switch k.Name {
	case key.NameDeleteBackward:
		if k.Modifiers.Contain(key.ModShortcut) {
			e.TrackerList.DeleteElements(true)
		}
		return
	case key.NameDeleteForward:
		e.TrackerList.DeleteElements(false)
		return
	case key.NameLeftArrow:
		delta = -1
	case key.NameRightArrow:
		delta = 1
	case key.NameHome:
		delta = -1e6
	case key.NameEnd:
		delta = 1e6
	case key.NameUpArrow:
		delta = -1
	case key.NameDownArrow:
		delta = 1
	case key.NamePageUp:
		delta = -1e6
	case key.NamePageDown:
		delta = 1e6
	}
	if k.Modifiers.Contain(key.ModShortcut) {
		e.TrackerList.MoveElements(delta)
	} else {
		e.TrackerList.SetSelected(e.TrackerList.Selected() + delta)
		if !k.Modifiers.Contain(key.ModShift) {
			e.TrackerList.SetSelected2(e.TrackerList.Selected())
		}
	}
	e.EnsureVisible(e.TrackerList.Selected())
}

func (l *DragList) EnsureVisible(item int) {
	first := l.List.Position.First
	last := l.List.Position.First + l.List.Position.Count - 1
	if item < first || (item == first && l.List.Position.Offset > 0) {
		l.List.ScrollTo(item)
	}
	if item > last || (item == last && l.List.Position.OffsetLast < 0) {
		o := -l.List.Position.OffsetLast + l.List.Position.Offset
		l.List.ScrollTo(item - l.List.Position.Count + 1)
		l.List.Position.Offset = o
	}
}

func (l *DragList) CenterOn(item int) {
	lenPerChildPx := l.List.Position.Length / l.TrackerList.Count()
	if lenPerChildPx == 0 {
		return
	}
	listLengthPx := l.List.Position.Count*l.List.Position.Length/l.TrackerList.Count() + l.List.Position.OffsetLast - l.List.Position.Offset
	lenBeforeItem := (listLengthPx - lenPerChildPx) / 2
	quot := lenBeforeItem / lenPerChildPx
	rem := lenBeforeItem % lenPerChildPx
	l.List.ScrollTo(item - quot - 1)
	l.List.Position.Offset = lenPerChildPx - rem
}

func between(a, b, c int) bool {
	return (a <= b && b <= c) || (c <= b && b <= a)
}

func intMax(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func intMin(a, b int) int {
	if a < b {
		return a
	}
	return b
}
