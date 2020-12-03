#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

ConVar ConVar_Casper_T = null;

Handle Handle_Casper_T[MAXPLAYERS] = null;

bool gorunmez[MAXPLAYERS] =  { false, ... };

public Plugin myinfo = 
{
	name = "Saklambaç Casper", 
	author = "ByDexter", 
	description = "Her yetkili 1 kez görünmez olabilir X saniye boyunca", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_casper", ZaGoremezsin, ADMFLAG_SLAY, "Yetkili hayalet");
	RegAdminCmd("sm_spy", ZaGoremezsin, ADMFLAG_SLAY, "Yetkili hayalet");
	HookEvent("round_start", Control_Round);
	HookEvent("player_death", Control_Dead);
	HookEvent("round_end", Control_Round);
	ConVar_Casper_T = CreateConVar("sm_invis_timer", "15.0", "Kaç saniye görünmez olsun");
	AutoExecConfig(true, "Casper", "ByDexter");
}

public void OnClientPostAdminCheck(int client)
{
	if (gorunmez[client])
		gorunmez[client] = false;
}

public Action ZaGoremezsin(int client, int args)
{
	if (!gorunmez[client] && IsPlayerAlive(client))
	{
		gorunmez[client] = true;
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		if (Handle_Casper_T[client] != null)
			delete Handle_Casper_T[client];
		Handle_Casper_T[client] = CreateTimer(ConVar_Casper_T.FloatValue, Simdigordumseni, client, TIMER_FLAG_NO_MAPCHANGE);
		ReplyToCommand(client, "[SM] \x04%d saniye \x01görünmezsin", ConVar_Casper_T.IntValue);
		return Plugin_Handled;
	}
	else if (gorunmez[client])
	{
		ReplyToCommand(client, "[SM] Bu tur zaten görünmez olmuşsun!");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action Control_Round(Event event, const char[] name, bool dontBroadcast)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && gorunmez[client])
		{
			SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
			if (Handle_Casper_T[client] != null)
			{
				delete Handle_Casper_T[client];
				Handle_Casper_T[client] = null;
			}
			gorunmez[client] = false;
		}
	}
}

public Action Control_Dead(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && gorunmez[client])
	{
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		if (Handle_Casper_T[client] != null)
		{
			delete Handle_Casper_T[client];
			Handle_Casper_T[client] = null;
		}
	}
}

public Action Simdigordumseni(Handle timer, any client)
{
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	PrintToChat(client, "[SM] \x04Artık görünüyorsun \x01diğer el tekrar kullanabilirsin");
	return Plugin_Stop;
}

public Action Hook_SetTransmit(int entity, int client)
{
	if (entity != client)
		return Plugin_Handled;
	
	return Plugin_Continue;
} 