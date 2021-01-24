

--to define a character in the script do the following:
--character("player", "You", {1, 1, 1})
--the first argument is the reference to the character in the script, the second is the name you will see in game when they speak or are referenced, the third is the color of their name.
--If your character is going to have art, create a folder with their reference name in the assets/graphics folder, you can place your images there.

--to create a scene, do the following:
--scene "start"
--this creates a scene, or a label in other engines, anything you put below that is now what happens, in order, when you goto that scene
--the first or 'starting" scene must be called "start".

--here are some more things you can presently do with the engine:

--goto "scene_name" --used at the end of a scene, when you want to go to a new scene

--goto_if "make_out" "confessed_love" "run_away"  --goto the first scene argument if you set the second argument variable to true, otherwise goes to the third argument scene

--set_variable "got_stefans_hat" "true"  --sets the first argument as a variable to true, useful for goto_if

--fade_in_background "market" "1" --the first argument refers to the name of an image in the backgrounds folder, the second argument is hold long it takes to fade in.

--fade_in_character "stefan" "stefan_neutral" "center" "1" --arguments: character reference (first argument when creating the character), the image name in the characters asset folder, the screen position (center, left, right), and
--how long it takes to fade in

--text "I placed down my last crate and sit on top of it, letting out a deep breath."  --This is how you have narration, for instance, when the player character is thinking.

--choice "Here you go, have one for free." "free_pie"  --opens the choice panel and asks the user to pick a choice. the first argument is the text, the second is the scene to go to when they click it.
--if you want multiple choices, put one or more choice tags in sequence.

--to define a comment in your script (useful for writing yourself notes) use two dashes like this -- and then put your comment after it

--this is not a comprehensive list of all the script functions, nor is the engine feature complete, so if you need help or something added, feel free to ask Sir_Silver ^^

book = {}
player = character("player", "You", {1, 1, 1})

scene "start"
    text "Whats your book called?"
    request_set_variable (book) "name"
    text "Cool, and what's your name?"
    request_set_variable (player) "name"
    text "Hi there $player.name$. Looking forward to reading $book.name$!"