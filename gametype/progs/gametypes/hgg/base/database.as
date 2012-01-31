/*
Copyright (C) 2012 hettoo

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

const int DB_VERSION = 0;
const cString DB_FILE = "users_";

const int MAX_DB_ITEMS = 2048;

class DataBase {
    Account@[] accounts;
    int size;
    bool has_root;
    cString file_name;

    DataBase() {
        accounts.resize(MAX_DB_ITEMS);
        size = 0;
        has_root = false;
    }

    void init() {
        file_name = data_file(DB_FILE + DB_VERSION);
    }

    void read() {
        size = -1;
        has_root = false;
        cString file = G_LoadFile(file_name);

        int index;
        int new_index = 0;
        do {
            index = new_index;
            @accounts[++size] = Account();
            new_index = accounts[size].read(file, index);
            if (accounts[size].level == LEVEL_ROOT)
                has_root = true;
        } while (new_index > index);
    }

    void add(Account @dbitem) {
        if (dbitem.ip == "")
            dbitem.ip = "127.0.0.1";
        @accounts[size++] = @dbitem;
        if (dbitem.level == LEVEL_ROOT)
            has_root = true;
    }

    Account @find(cString &id) {
        for (int i = 0; i < size; i++) {
            if (accounts[i].id == id)
                return accounts[i];
        }
        return null;
    }

    void write() {
        cString file = "// " + gametype.getName() + " user database version "
            + DB_VERSION + "\n";
        for (int i = 0; i < size; i++)
            accounts[i].write(file);
        G_WriteFile(file_name, file);
    }
}