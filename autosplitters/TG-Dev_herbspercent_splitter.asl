state("TG-Dev") {
    // the room the player is currently in 
    // (includes title and end screens)
    int room : "TG-Dev.exe", 0xDA1728;
    // in gamer timer in 60ths of a second
    double timer : "TG-Dev.exe", 0x00DC8F60, 0x110, 0xEC0;
    // number of atropa flowers the player has collected so far
    double atropaCount : "TG-Dev.exe", 0x00B91A50, 0x30, 0xD90, 0xB0;
    // is the game currently paused (0 for no, 1 for yes)
    double isPaused : "TG-Dev.exe", 0x00B91BA8, 0x170, 0x510;
}

start {
    // start the timer when the in-game timer starts
    return old.timer == 0.0 && current.timer > 0.0;
}

split {

    // split when an atropa flower is collected or the end screen is up (19 is the room id for the end screen)
    // or the tutorial is completed (moved from room 3 to 4)
    return ((current.atropaCount != 0 && current.atropaCount == old.atropaCount + 1) || 
            (current.room == 19 && old.room == 18) ||
            (current.room == 4 && old.room == 3));
}

isLoading {
    // detect if the game is paused
    // also if the game hasn't started yet
    return current.isPaused == 1.0 || current.timer == 0.0;
}

gameTime{
    // sync with in-game time
    int timeRemaining = (int) current.timer;

    int days = 0;

    int hours = timeRemaining / (60*60*60);
    timeRemaining -= hours * 60 * 60 * 60;

    int minutes = timeRemaining / (60*60);
    timeRemaining -= minutes * 60 * 60;

    int seconds = timeRemaining / 60;
    timeRemaining -= seconds * 60;

    // need to convert to milliseconds
    int milliseconds = (int) (((double) timeRemaining) * (1000.0/60.0));

    return new TimeSpan(days, hours, minutes, seconds, milliseconds);
}

reset {
    // reset when in-game time resets
    return current.timer <= 0.0 || current.timer < old.timer;
}