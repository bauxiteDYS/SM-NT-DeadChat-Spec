#define MAX_MESSAGE_LENGTH 256
#define NT_MAXPLAYERS     33

new	String:message[MAX_MESSAGE_LENGTH],
	bool:targets[NT_MAXPLAYERS + 1], bool:IsTeamChat;

public Plugin:myinfo =
{
	name        = "NT Dead Chat Spec",
	author      = "Root, ported to NT by bauxite",
	description = "Allows dead players to text chat with living teammates, spectators can always chat with everyone",
	version     = "0.1.0",
}

public OnPluginStart()
{
	HookUserMessage(GetUserMessageId("SayText"), SayTextHook);
	HookEvent("player_say", Event_PlayerSay, EventHookMode_Post);
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
	for (new target = 1; target <= MaxClients; target++)
	{
		targets[target] = true;
	}
	
	IsTeamChat = StrEqual(command, "say_team", false);
}

public Action:SayTextHook(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	BfReadString(bf, message, sizeof(message));

	for (new i; i < playersNum; i++)
	{
		targets[players[i]] = false;
	}
}

public Event_PlayerSay(Handle:event, const String:name[], bool:dontBroadcast)
{
	new clients[MaxClients], numClients, client, i;

	client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsTeamChat)
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == GetClientTeam(client) && targets[i])
			{
				clients[numClients++] = i;
			}
			
			targets[i] = false;
		}
	}
	else
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && targets[i] && GetClientTeam(client) == 1)
			{
				clients[numClients++] = i;
			}
			
			targets[i] = false;
		}
	}

	new Handle:SayText = StartMessage("SayText", clients, numClients, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);

	if (SayText != INVALID_HANDLE)
	{
		BfWriteByte(SayText, client);

		BfWriteString(SayText, message);

		BfWriteByte(SayText, -1);

		EndMessage();
	}
}
