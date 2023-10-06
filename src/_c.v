module dialog

#flag @VMODROOT/src/osdialog/osdialog.c
#flag darwin @VMODROOT/src/osdialog/osdialog_mac.m -framework AppKit
#flag windows @VMODROOT/src/osdialog/osdialog_win.c -lcomdlg32
$if gtk2 ? {
	#flag linux @VMODROOT/src/osdialog/osdialog_gtk2.c
} $else {
	#flag linux @VMODROOT/src/osdialog/osdialog_gtk3.c
}

#include "@VMODROOT/src/osdialog/osdialog.h"

$if macos {
	#include <AppKit/AppKit.h>
} $else $if linux {
	#pkgconfig gtk+-3.0
}

[typedef]
struct C.osdialog_color {
	r u8
	g u8
	b u8
	a u8
}

fn C.osdialog_message(level int, buttons int, message &char) int
fn C.osdialog_file(action int, path &char, filename &char, filters C.osdialog_filters) &char
fn C.osdialog_color_picker(color &C.osdialog_color, opacity int) int

fn dialog_c__file_dialog() ?string {
	path := C.osdialog_file(int(FileAction.open), unsafe { nil }, unsafe { nil }, unsafe { nil })
	unsafe {
		if path != nil {
			return path.vstring()
		}
	}
	return none
}

fn dialog_c__message(text string, opts MessageOptions) bool {
	return if C.osdialog_message(int(opts.level), int(opts.buttons), &char(text.str)) == 1 {
		true
	} else {
		false
	}
}

fn dialog_c__color_picker(opts ColorPickerOptions) ?Color {
	color := &opts.color
	if C.osdialog_color_picker(color, int(opts.opacity)) == 1 {
		return *color
	}
	return none
}
