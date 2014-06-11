

// Hopefully in a future update the entire spawn menu will be moved to Lua
// For now, in your gamemode, you could use the spawn menu keys to do something else


/*---------------------------------------------------------
  Called when spawnmenu is trying to be opened. 
   Return false to dissallow it.
---------------------------------------------------------*/
function GM:SpawnMenuOpen()
	return false
end

/*---------------------------------------------------------
  Called when context menu is trying to be opened. 
   Return false to dissallow it.
---------------------------------------------------------*/
function GM:ContextMenuOpen()
	return false	
end
