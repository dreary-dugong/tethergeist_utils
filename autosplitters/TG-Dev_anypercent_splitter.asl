state("TG-Dev") {
    // the room the player is currently in 
    // (includes title and end screens)
    int room : "TG-Dev.exe", 0xDA1728;
    // in gamer timer in 60ths of a second
    double timer : "TG-Dev.exe", 0x00DC8F60, 0x110, 0xEC0;
    // is the game currently paused (0.0 for no, 1.0 for yes)
    double isPaused : "TG-Dev.exe", 0x00B91BA8, 0x170, 0x510;
}

init {
    // keep track of which rooms the player has already entered
    vars.rooms = new List<int>();
    vars.rooms.Add(0);
}

start {
    // start the timer when the in-game timer starts
    return old.timer == 0.0 && current.timer > 0.0;
}

split {
    // split when room increases to one we haven't seen yet
    if (current.room == old.room + 1 && !vars.rooms.Contains(current.room)) {
        vars.rooms.Add(current.room);
        return true;
    }
    return false;
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