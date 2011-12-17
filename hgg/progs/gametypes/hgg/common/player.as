/*
Copyright (C) 2011 hettoo

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

class Player {
    cClient @client;
    int row;
    int minutes_played;

    int title;
    int level;
    int exp;
    int max_row;
    int total_kills;
    int total_deaths;
    int total_minutes_played;

    void stats_from_db() {
        title = 0;
        level = 0;
        exp = 0;
        max_row = 0;
        total_kills = 0;
        total_deaths = 0;
        total_minutes_played = 0;
    }

    void stats_to_db() {
    }

    void init(cClient @new_client) {
        @client = @new_client;
        row = 0;
        minutes_played = 0;

        stats_from_db();
    }

    void welcome(cString &msg) {
        client.addAward(msg);
    }

    void show_row() {
        client.addAward(S_COLOR_ROW + row + "!");
    }

}
