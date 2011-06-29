had to migrate nether from vanilla to craftbukkit,
look at nether.PNG or reference 
http://forums.bukkit.org/threads/using-a-vanilla-nether-into-bukkit.19523/

basic steps

1. Don't change your setup. Really, you can lose data perminantly.

2. Drop craftbukkit in the local directory and run it. Let craftbukkit
   generate new nether for you. It'll be in world_nether/.  Wait for 
   craftbukkit to finish processing.

3. Stop craftbukkit respectfully. Enter the craftbukkit command line
   and type "stop". Wait for it to finish.

4. In the new world_nether/ folder, delete DIM-1/.  Copy world/DIM-1/
   to your world_nether/ folder. Leave the other files alone.

5. Restart craftbukkit. It should load your vanilla's nether.
