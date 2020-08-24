#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

ConVar ConVar_Casper_T;

Handle Handle_Casper_T;

int gorunmez [MAXPLAYERS + 1] = 0;

public Plugin myinfo = 
{
	name = "Saklambaç Casper",
	author = "ByDexter",
	description = "Her yetkili 1 kez görünmez olabilir X saniye boyunca",
	version = "1.0",
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_casper", ZaGoremezsin, ADMFLAG_SLAY, "Yetkili hayalet");
	RegAdminCmd("sm_spy", ZaGoremezsin, ADMFLAG_SLAY, "Yetkili hayalet");
	HookEvent("round_start", Control_RStart);
	HookEvent("player_death", Control_Optimize);
	HookEvent("round_end", Control_Optimize);
	ConVar_Casper_T = CreateConVar("sm_invis_timer", "15.0", "Kaç saniye görünmez olsun");
	AutoExecConfig(true, "Casper", "ByDexter");
}


public void OnMapEnd()
{
	for (int client = 1; client <= MaxClients; client++)
	if(gorunmez[client] == 1)
	{
		gorunmez[client] = 0;
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		delete Handle_Casper_T;
	}
}

public Action ZaGoremezsin(int client, int args)
{
	if(gorunmez[client] == 0 && IsPlayerAlive(client))
	{
		gorunmez[client] = 1;
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		Handle_Casper_T = CreateTimer(ConVar_Casper_T.FloatValue, Simdigordumseni, client, TIMER_FLAG_NO_MAPCHANGE);
		CPrintToChat(client, "{darkred}[ByDexter] {green}%d saniye {default}görünmezsin", ConVar_Casper_T.IntValue);
	}
}

public Action Control_Optimize(Handle event, const char[] name, bool dontBroadcast)
{
	for (int client = 1; client <= MaxClients; client++)
	if(gorunmez[client] == 1)
	{
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		delete Handle_Casper_T;
	}
}

public Action Simdigordumseni(Handle timer, any client)
{
	gorunmez[client] = 2;
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	CPrintToChat(client, "{darkred}[ByDexter] {green}artık görünüyorsun {default}diğer el tekrar kullanabilirsin");
}

public Action Control_RStart(Handle event, const char[] name, bool dontBroadcast)
{
	for (int client = 1; client <= MaxClients; client++)
	gorunmez[client] = 0;
}

public Action Hook_SetTransmit(int entity, int client) 
{
    if (entity != client) 
        return Plugin_Handled;
     
    return Plugin_Continue; 
}