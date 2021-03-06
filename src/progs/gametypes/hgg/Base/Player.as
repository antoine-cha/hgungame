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

enum AccountStates {
    AS_UNKNOWN,
    AS_WRONG_IP,
    AS_IDENTIFIED
};

class Player {
    bool inited;
    Client @client;
    bool alive;
    bool greeted;
    int[] ammo;
    int row;
    int minutesPlayed;

    int score;

    int state;
    Account @account;

    Player () {
        inited = false;
        alive = false;
        greeted = false;
        ammo.resize(WEAP_TOTAL);
    }

    void init(Client @newClient, Database @db) {
        bool update = @client == @newClient;
        if (!update) {
            if (@newClient == null || inited)
                return;
            else
                inited = true;

            @client = @newClient;
            row = 0;
            minutesPlayed = 0;
            score = 0;
        }

        Account @backup = @account;
        @account = db.find(raw(client.get_name()));
        if (@account == null) {
            if (!update || state != AS_UNKNOWN) {
                state = AS_UNKNOWN;
                @account = @Account();
                account.init(client);
            } else {
                @account = @backup;
            }
        } else {
            String ip = getIP(client);
            if (ip == account.ip || (ip == "" && account.ip == "127.0.0.1"))
                state = AS_IDENTIFIED;
            else
                state = AS_WRONG_IP;
        }
    }

    void resetRow() {
        row = 0;
    }

    void putTeam(int team, bool ghost) {
        client.team = team;
        client.respawn(ghost);
    }

    void putTeam(int team) {
        putTeam(team, team == TEAM_SPECTATOR || client.getEnt().isGhosting());
    }

    void forceSpec(String &msg) {
        putTeam(TEAM_SPECTATOR, true);
        client.addAward(S_COLOR_BAD + msg);
    }

    bool ipCheck() {
        if (state == AS_WRONG_IP) {
            forceSpec("Wrong IP");
            return false;
        }
        return true;
    }

    void setRegistered(String &password) {
        state = AS_IDENTIFIED;
        account.setPassword(password);
    }

    void setLevel(int level) {
        administrate("You are now a level " + level + " user!");
        account.level = level;
    }

    void greet(Levels @levels) {
        if (!greeted && state == AS_IDENTIFIED) {
            notify(levels.greeting(account.level, client.get_name()));
            greeted = true;
        }
    }

    void instruct(bool greeted) {
        if (!greeted)
            say(S_COLOR_SPECIAL + "Welcome " + S_COLOR_RESET + client.get_name()
                    + S_COLOR_SPECIAL + " and have fun!");
        say(S_COLOR_SPECIAL + "Use /" + COMMAND_BASE
                + " to see its subcommands you may use here.");
    }

    void syncScore() {
        client.stats.setScore(score);
    }

    void addScore(int n) {
        score += n;
        syncScore();
    }

    void setScore(int n) {
        score = n;
        syncScore();
    }

    void showRow() {
        client.addAward(S_COLOR_ROW + row + "!");
    }

    void killer() {
        row++;
        account.addKill();
    }

    void updateAmmo() {
        for (int i = 0; i < WEAP_TOTAL; i++)
            ammo[i] = clientAmmo(client, i);
    }

    void killed() {
        account.addDeath();
    }

    void addMinute() {
        minutesPlayed++;
        account.addMinute();
    }

    bool updateRow() {
        if (forReal())
            return account.updateRow(row);
        return false;
    }

    int getAmmo(int weapon) {
        return ammo[weapon];
    }

    void updateHUDSelf() {
        if (client.team == TEAM_SPECTATOR)
            return;

        int configIndex = CS_GENERAL + client.playerNum + 2;
        client.setHUDStat(STAT_MESSAGE_ALPHA, configIndex);
        G_ConfigString(configIndex, "[ " + score + " ]");
    }

    void updateHUDOther(Players @players) {
        if (@client == null || client.team == TEAM_SPECTATOR)
            return;

        int configIndex = CS_GENERAL;
        if (score == players.bestScore)
            configIndex++;
        client.setHUDStat(STAT_MESSAGE_BETA, configIndex);
        if (players.bestScore == UNKNOWN
                || (score == players.bestScore
                    && players.secondScore == UNKNOWN) || players.count() == 0)
            G_ConfigString(configIndex, "[ ? ]");
        else
            G_ConfigString(configIndex, "[ "
                    + (score == players.bestScore ? players.secondScore
                        : players.bestScore) + " ]");
    }

    void updateHUDTeams(int countAlpha, int countBeta) {
        client.setHUDStat(STAT_MESSAGE_ALPHA, CS_GENERAL);
        G_ConfigString(CS_GENERAL, "- " + countAlpha + " -");
        client.setHUDStat(STAT_MESSAGE_BETA, CS_GENERAL + 1);
        G_ConfigString(CS_GENERAL + 1, "- " + countBeta + " -");
    }

    void print(String &msg) {
        client.printMessage(msg);
    }

    void center(String &msg) {
        G_CenterPrintMsg(client.getEnt(), msg);
    }

    void say(String &msg) {
        print(msg + "\n");
    }

    void sayBad(String &msg) {
        say(S_COLOR_BAD + msg);
    }

    void administrate(String &msg) {
        client.addAward(S_COLOR_ADMINISTRATIVE + msg);
    }
}
