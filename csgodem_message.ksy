meta:
  id: message
  endian: le
  imports:
    - /common/vlq_base128_le

seq:
  - id: msg_type_id
    type: vlq_base128_le
  - id: length
    type: vlq_base128_le
  - id: body
    size: length.value


#net_NOP = 0;
#net_Disconnect = 1;				// disconnect, last message in connection
#net_File = 2;					// file transmission message request/deny
#net_Tick = 4; 					// s->c world tick, c->s ack world tick
#net_StringCmd = 5; 				// a string command
#net_SetConVar = 6;				// sends one/multiple convar/userinfo settings
#net_SignonState = 7;			// signals or acks current signon state

#svc_ServerInfo 			= 8;		// first message from server about game; map etc
#svc_SendTable 			= 9;		// sends a sendtable description for a game class
#svc_ClassInfo 			= 10;		// Info about classes (first byte is a CLASSINFO_ define).							
#svc_SetPause 			= 11;		// tells client if server paused or unpaused
#svc_CreateStringTable 	= 12;		// inits shared string tables
#svc_UpdateStringTable 	= 13;		// updates a string table
#svc_VoiceInit 			= 14;		// inits used voice codecs & quality
#svc_VoiceData 			= 15;		// Voicestream data from the server
#svc_Print 				= 16;		// print text to console
#svc_Sounds 				= 17;		// starts playing sound
#svc_SetView 			= 18;		// sets entity as point of view
#svc_FixAngle 			= 19;		// sets/corrects players viewangle
#svc_CrosshairAngle 		= 20;		// adjusts crosshair in auto aim mode to lock on traget
#svc_BSPDecal 			= 21;		// add a static decal to the world BSP
#svc_UserMessage 		= 23;		// a game specific message 
#svc_GameEvent 			= 25;		// global game event fired
#svc_PacketEntities 		= 26;		// non-delta compressed entities
#svc_TempEntities 		= 27;		// non-reliable event object
#svc_Prefetch 			= 28;		// only sound indices for now
#svc_Menu 				= 29;		// display a menu from a plugin
#svc_GameEventList 		= 30;		// list of known games events and fields
#svc_GetCvarValue 		= 31;		// Server wants to know the value of a cvar on the client	