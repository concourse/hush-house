TEAMS = $(shell ls ./teams)

# Performs a `fly set-team` for each team in the list of
# teams defined under `./teams`.
#
# ps.: you must be already logged in, having a target named
# `hh` whose default team is `main`.
#
set-teams: $(addprefix set-team-, $(TEAMS))

set-team-%:
	fly --target hh \
		set-team \
		--non-interactive \
		--team-name=$* \
		--config=./teams/$*
