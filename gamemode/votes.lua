Vote = {}
Votes = {}

function ccDoVote(ply, cmd, args)
	if not Votes[args[1]] then return end
	if not Votes[args[1]][tonumber(args[2])] then return end

	Votes[args[1]]:HandleNewVote(ply, tonumber(args[2]))
end
concommand.Add("vote", ccDoVote)

function Vote:HandleNewVote(ply, id)
	self[id] = self[id] + 1

	umsg.Start("KillVoteVGUI", ply)
		umsg.String(self.ID)
	umsg.End()

	if self[1] + self[2] >= #player.GetAll() then
		vote.HandleVoteEnd(self.ID)
	end
end

vote = {}

function vote:Create(question, voteid, ent, delay, callback)
	local newvote = {}

	for k, v in pairs(Vote) do newvote[k] = v end

	newvote.ID = voteid
	newvote.Callback = callback
	newvote.Ent = ent

	newvote[1] = 0
	newvote[2] = 0

	Votes[voteid] = newvote

	umsg.Start("DoVote")
		umsg.String(question)
		umsg.String(voteid)
	umsg.End()

	timer.Create(voteid .. "timer", delay, 1, vote.HandleVoteEnd, voteid)
end

function vote.DestroyVotesWithEnt(ent)
	for k, v in pairs(Votes) do
		if v.Ent == ent then
			umsg.Start("KillVoteVGUI")
				umsg.String(v.ID)
			umsg.End()

			Votes[k] = nil
		end
	end
end

function vote.HandleVoteEnd(id)
	if not Votes[id] then return end

	local choice = 1

	if Votes[id][2] >= Votes[id][1] then choice = 2 end

	Votes[id].Callback(choice, Votes[id].Ent)

	umsg.Start("KillVoteVGUI")
		umsg.String(id)
	umsg.End()

	Votes[id] = nil
end