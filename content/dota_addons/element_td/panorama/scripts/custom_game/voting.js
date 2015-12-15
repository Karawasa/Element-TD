"use strict";

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );			// Heroes and team score at the top of the HUD

var gamesettings = {};

var votingUI = $( "#Voting" );
var voteResultsUI = $( '#VoteResults' );
var buttonVote = $( "#Vote" );
var buttonResults = $( "#ResultsButton" );
var info = $( '#Info' );
var votingLiveUI = $( '#VotingLive' );

var notVotedUI = $( '#NotVoted' );

var votingLiveNotVoted = $( '#NotVotedPlayers' );
var votingLiveHasVoted = $( '#HasVotedPlayers' );
var playerVotes = {};

var gamemodeDD = $( '#GamemodeDD' );
var difficultyDD = $( '#DifficultyDD' );
var elementDD = $( '#ElementsDD' );
var orderDD = $( '#OrderDD' );
var lengthDD = $( '#LengthDD' );

var gamemodeDesc = $( '#GamemodeDesc' );
var difficultyDesc = $( '#DifficultyDesc' );
var elementDesc = $( '#ElementsDesc' );
var orderDesc = $( '#OrderDesc' );
var lengthDesc = $( '#LengthDesc' );

var timer = $( '#Countdown' );

var gamemodeResults = $( '#GamemodeResult' );
var difficultyResults = $( '#DifficultyResult' );
var elementsResults = $( '#ElementsResult' );
var orderResults = $( '#OrderResult' );
var lengthResults = $( '#LengthResult' );

var gameModes = {};
var difficultyModes = {};
var elementModes = {};
var orderModes = {};
var lengthModes = {};

function Setup()
{
	voteResultsUI.visible = false;
	votingUI.visible = false;
	info.visible = false;
	votingLiveUI.visible = false;
	UpdateNotVoted();
}

function ToggleVoteDialog( data )
{
	votingUI.visible = data.visible;
	if (Game.GetAllPlayerIDs().length > 1)
		votingLiveUI.visible = true;
}

function Populate( data )
{
	gamesettings = data;

	//=Gamemodes Dropdown================================================================//
	for (var gm in gamesettings.GameModes)
	{
		var gamemode = gamesettings['GameModes'][gm];
		gameModes[parseInt(gamemode['Index'])] = [ gamemode['Name'], gamemode['Description'], gm ];
	}

	PopulateDropDown(gamemodeDD, gameModes);
	gamemodeDD.SetSelected(0);
	gamemodeDesc.text = gameModes[0][1]; // Default Competitive

	//=Difficulty Dropdown================================================================//
	for (var df in gamesettings.Difficulty)
	{
		var difficulty = gamesettings['Difficulty'][df];
		var desc = (parseFloat(difficulty.Health) * 1000) / 10 + "% Creep Health, " + parseInt(difficulty.BaseBounty * 1000)/1000+ " Base Bounty (Express Mode: " + parseInt(difficulty.BaseBountyExpress * 1000)/1000+ " Base Bounty)";
		difficultyModes[parseInt(difficulty['Index'])] = [ difficulty['Name'], desc, df ];
	}

	PopulateDropDown(difficultyDD, difficultyModes);
	difficultyDD.SetSelected(0);
	difficultyDesc.text = difficultyModes[0][1]; // Default Normal

	//=Elements Dropdown================================================================//
	for (var ele in gamesettings.ElementModes)
	{
		var element = gamesettings['ElementModes'][ele];
		elementModes[parseInt(element['Index'])] = [ element['Name'], element['Description'], ele ];
	}

	PopulateDropDown(elementDD, elementModes);
	elementDD.SetSelected(0);
	elementDesc.text = elementModes[0][1]; // Default All Pick

	//=Order Dropdown================================================================//
	for (var ord in gamesettings.CreepOrder)
	{
		var order = gamesettings['CreepOrder'][ord];
		orderModes[parseInt(order['Index'])] = [ order['Name'], order['Description'], ord ];
	}

	PopulateDropDown(orderDD, orderModes);
	orderDD.SetSelected(0);
	orderDesc.text = orderModes[0][1]; // Default Normal

	//=Length Dropdown================================================================//
	for (var lnth in gamesettings.GameLength)
	{
		var gameLength = gamesettings['GameLength'][lnth];
		var desc = "Start at wave " + gameLength.Wave + " with " + gameLength.Gold + " Gold and " + gameLength.Lumber + " Lumber."
		lengthModes[parseInt(gameLength['Index'])] = [ gameLength['Name'], desc, lnth ];
	}

	PopulateDropDown(lengthDD, lengthModes);
	lengthDD.SetSelected(0);
	lengthDesc.text = lengthModes[0][1]; // Default Classic
}

function PopulateDropDown( DropDown, items )
{
	for (var item in items)
	{
		var label = $.CreatePanel("Label", DropDown, item);
		label.text = items[item][0];
		DropDown.AddOption(label);
	}
}

function OnDropDownChanged( setting )
{
	if (setting == "gamemode")
		gamemodeDesc.text = gameModes[parseInt(gamemodeDD.GetSelected().id)][1]; 
	else if (setting == "difficulty")
		difficultyDesc.text = difficultyModes[parseInt(difficultyDD.GetSelected().id)][1];
	else if (setting == "elements")
		elementDesc.text = elementModes[parseInt(elementDD.GetSelected().id)][1];
	else if (setting == "order")
		orderDesc.text = orderModes[parseInt(orderDD.GetSelected().id)][1];
	else if (setting == "length")
		lengthDesc.text = lengthModes[parseInt(lengthDD.GetSelected().id)][1];
}

function UpdateVoteTimer( data )
{
	timer.text = data.time;
}

function UpdateNotVoted()
{
	var players = Game.GetAllPlayerIDs();
	$.Msg("IDs: " + players);
	votingLiveNotVoted.RemoveAndDeleteChildren();
	var position = 0;
	for (var playerID in players) {
		if (!playerVotes[playerID]) {
			var playerData = Game.GetPlayerInfo(parseInt(playerID));
			$.Msg(playerData);
			var notVoted = $.CreatePanel('DOTAAvatarImage', votingLiveNotVoted, '');
			notVoted.AddClass('VotingAvatar');
			notVoted.AddClass('NotVoted');
			notVoted.steamid = playerData.player_steamid;
			if (position == 1 || position == 5)
				notVoted.AddClass('Col1');
			else if (position == 2 || position == 6)
				notVoted.AddClass('Col2');
			else if (position == 3 || position == 7)
				notVoted.AddClass('Col3');
			if (position == 4 || position == 5 || position == 6 || position == 7)
				notVoted.AddClass('SecondLine');
			position += 1;
		}
	};
	if (position == 0)
	{
		notVotedUI.style['visibility'] = "collapse";
		$.Schedule(3, function(){votingLiveUI.visible = false;});
	}
}

function PlayerVoted( data )
{
	$.Msg(data);
	var playerID = data.playerID;
	var playerData = Game.GetPlayerInfo(parseInt(playerID));
	var vote = $.CreatePanel('Panel', votingLiveHasVoted, '');
	vote.AddClass('VotedPlayer');

	var avatar = $.CreatePanel('DOTAAvatarImage', vote, '');
	avatar.AddClass('VotingAvatar');
	avatar.steamid = playerData.player_steamid;

	var votes = $.CreatePanel('Panel', vote, '');
	votes.AddClass('VotedPlayerVotes');

	var gamemode = $.CreatePanel('Label', votes, '');
	gamemode.AddClass('PlayerVote');
	gamemode.text = data.gamemode;

	var difficulty = $.CreatePanel('Label', votes, '');
	difficulty.AddClass('PlayerVote');
	difficulty.text = data.difficulty;

	var elements = $.CreatePanel('Label', votes, '');
	elements.AddClass('PlayerVote');
	elements.text = data.elements;

	var order = $.CreatePanel('Label', votes, '');
	order.AddClass('PlayerVote');
	order.text = data.order;

	var length = $.CreatePanel('Label', votes, '');
	length.AddClass('PlayerVote');
	length.text = data.length;

	playerVotes[playerID] = true;
	UpdateNotVoted();
}

function ConfirmVote()
{
	Game.EmitSound("ui_generic_button_click");

	buttonVote.visible = false;
	info.visible = true;

	gamemodeDD.enabled = false;
	difficultyDD.enabled = false;
	elementDD.enabled = false;
	orderDD.enabled = false;
	lengthDD.enabled = false;

	var data = {};

	data['gamemodeVote'] = gameModes[parseInt(gamemodeDD.GetSelected().id)][2]; 
	data['difficultyVote'] = difficultyModes[parseInt(difficultyDD.GetSelected().id)][2];
	data['elementsVote'] = elementModes[parseInt(elementDD.GetSelected().id)][2];
	data['orderVote'] = orderModes[parseInt(orderDD.GetSelected().id)][2];
	data['lengthVote'] = lengthModes[parseInt(lengthDD.GetSelected().id)][2];

	var playerID = Players.GetLocalPlayer();

	GameEvents.SendCustomGameEventToServer( "etd_player_voted", { "PlayerID" : playerID, "data" : data } );
}

function ShowVoteResults( data )
{
	votingUI.visible = false;
	voteResultsUI.visible = true;

	gamemodeResults.text = gamesettings['GameModes'][data.gamemode].Name;
	difficultyResults.text = gamesettings['Difficulty'][data.difficulty].Name;
	elementsResults.text = gamesettings['ElementModes'][data.elements].Name;
	orderResults.text = gamesettings['CreepOrder'][data.order].Name;
	lengthResults.text = gamesettings['GameLength'][data.length].Name;
}

function ResultsClose()
{
	Game.EmitSound("ui_generic_button_click");
	voteResultsUI.visible = false;
	votingLiveUI.visible = false;
}

(function () {
	Setup();
	GameEvents.Subscribe( "etd_toggle_vote_dialog", ToggleVoteDialog );
  	GameEvents.Subscribe( "etd_update_vote_timer", UpdateVoteTimer );
  	GameEvents.Subscribe( "etd_populate_vote_table", Populate );
  	GameEvents.Subscribe( "etd_vote_display", PlayerVoted );
  	GameEvents.Subscribe( "etd_vote_results", ShowVoteResults );
})();