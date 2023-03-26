#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

ConVar caspertime = null;

bool invis[65] = { false, ... };

Handle invistimer[65] = { null, ... };

public Plugin myinfo = 
{
	name = "Saklambaç Casper", 
	author = "ByDexter", 
	description = "Her yetkili 1 kez görünmez olabilir X saniye boyunca", 
	version = "1.2", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_casper", Command_Casper, ADMFLAG_SLAY);
	RegAdminCmd("sm_spy", Command_Casper, ADMFLAG_SLAY);
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", OnClientDead);
	
	caspertime = CreateConVar("sm_casper_timer", "10", "Kaç saniye görünmez olsun", 0, true, 0.1);
	AutoExecConfig(true, "Saklambac_Casper", "ByDexter");
}

public void OnClientPostAdminCheck(int client)
{
	invis[client] = false;
	if (invistimer[client] != null)
	{
		delete invistimer[client];
		invistimer[client] = null;
	}
}

public Action Command_Casper(int client, int args)
{
	if (!IsPlayerAlive(client))
	{
		ReplyToCommand(client, "[SM] Bu komutu ölüyken kullanamazsın.");
		return Plugin_Handled;
	}
	if (invis[client])
	{
		ReplyToCommand(client, "[SM] Bu komutu bu tur tekrar kullanamazsın.");
		return Plugin_Handled;
	}
	
	invistimer[client] = CreateTimer(caspertime.FloatValue, RemoveInvis, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	ReplyToCommand(client, "[SM] %d saniye boyunca görünmezsin.", caspertime.IntValue);
	
	return Plugin_Handled;
}

public Action RoundStart(Event event, const char[] name, bool dB)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmit);
			if (invistimer[i] != null)
			{
				delete invistimer[i];
				invistimer[i] = null;
			}
			invis[i] = false;
		}
	}
	return Plugin_Continue;
}

public Action OnClientDead(Event event, const char[] name, bool dB)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(victim) && invistimer[victim] != null)
	{
		delete invistimer[victim];
		invistimer[victim] = null;
	}
	return Plugin_Continue;
}

public Action RemoveInvis(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		invistimer[client] = null;
	}
	return Plugin_Stop;
}

public Action Hook_SetTransmit(int entity, int client)
{
	if (entity != client)
		return Plugin_Handled;
	
	return Plugin_Continue;
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 