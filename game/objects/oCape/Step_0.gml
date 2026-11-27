x = oLink.x;
y = oLink.y;

if(global.Paused || oCamera.RoomTransition != NONE || oLink.State == LinkState.AutoMove || oLink.State == LinkState.Idle || oLink.State == LinkState.Falling || oLink.State == LinkState.Warping) ObjIncAlarms();

if(oLink.House_Entering || oLink.House_Leaving) instance_destroy(id);

if(Inventory_NoItemIsEquiped){
	
	instance_destroy(id);
	
}else if(Inventory_EquipedItem.ItemClass != ItemClass.Cape){

	instance_destroy(id);

}