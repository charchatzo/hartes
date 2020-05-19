/*
* Copyright (c) {{yearrange}} charalabos ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: charalabos <>
*/
using Granite;
using Granite.Widgets;
using Gtk;
using WebKit;

public class welcomeview : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.Welcome ("Deep dive", "This is a simple web browser.\nChanges: Dark mode switch added");

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    try {
                        AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
                case 1:
                    try {
                        AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
            }
        });
    }
}


namespace Test {
    public class Application : Granite.Application {

        public Application () {
            Object(
                application_id: "com.github.Deep-dive",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }



        protected override void activate () {
            var window = new Gtk.ApplicationWindow (this);
            var main_grid = new Gtk.Grid ();
            var headerbar = new Gtk.HeaderBar ();
            var searchbar = new Gtk.Entry ();
            var browser = new WebView ();
            var back = new Gtk.Button.with_label ("<-");
            var forward = new Gtk.Button.with_label ("->");
            var reload = new Gtk.Button.with_label ("⟳");
            var gtk_settings = Gtk.Settings.get_default ();
            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            var switcher = new Gtk.StackSwitcher ();
            var stack = new Gtk.Stack ();
            var settings_section = new Gtk.Grid ();
            var dark_mode_label = new Gtk.Label ("Dark mode.");

            browser.load_uri ("https://google.com");

            settings_section.attach (mode_switch, 0, 0, 10, 10);
            settings_section.attach_next_to (dark_mode_label, mode_switch, Gtk.PositionType.LEFT, 10, 10);
            
            switcher.stack = stack;
            stack.expand = true;
            stack.add_titled (browser, "browser_section_stacked", "Browser");
            stack.add_titled (settings_section, "settings_section_stacked", "Settings");
            
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            var wv = new welcomeview ();

            var welcomemessage = new Gtk.Window ();

            welcomemessage.add (wv);
            welcomemessage.set_title ("About");

            main_grid.attach (back, 0, 0, 1, 1);
            main_grid.attach_next_to (forward, back, Gtk.PositionType.RIGHT, 1, 1);
            main_grid.attach_next_to (reload, forward, Gtk.PositionType.RIGHT, 1, 1);

            reload.clicked.connect (() => {
                browser.reload ();
            });

            searchbar.valign = Gtk.Align.CENTER;
            searchbar.set_size_request (900, 10);

            browser.load_changed.connect (() => {
                searchbar.set_text (browser.uri);
            });

            searchbar.activate.connect (() => {
                browser.load_uri (searchbar.text);
            });

            back.clicked.connect (() => {
                browser.go_back ();
            });

            forward.clicked.connect (() => {
                browser.go_forward ();
            });

            headerbar.set_show_close_button (true);
            headerbar.set_custom_title (searchbar);
            headerbar.pack_end (main_grid);
            headerbar.pack_start (switcher);
            window.set_titlebar (headerbar);

            window.set_default_size (900, 640);
            window.add (stack);
            window.show_all ();
            welcomemessage.show_all ();
        }



        public static int main (string[] args) {
            var app = new Test.Application ();
            return app.run (args);
        }
    }
}
