/*
Copyright (C) 2012 Gerco van Heerdt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

const int MAX_COLUMNS = 16;

class Table {
    int[] sizes;
    int columns;
    int i;
    String string;

    Table() {
        sizes.resize(MAX_COLUMNS);
        reset();
    }

    void addColumn(const String &name, int size) {
        string += fixedField(name, size);
        sizes[columns++] = size;
    }

    void add(const String &field) {
        if (i == 0)
            string += "\n";
        string += fixedField(field, sizes[i]);
        i = (i + 1) % columns;
    }

    void add(int field) {
        add(field + "");
    }

    String @getString() {
        return string + (i == 0 && string != "" ? "\n" : "");
    }

    void reset() {
        columns = 0;
        i = 0;
        string = "";
    }
}
