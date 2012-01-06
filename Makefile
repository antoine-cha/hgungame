VERSION = 0.0-dev

VERSION_WORD = $(subst .,_,$(VERSION))
GT_PK3 = hgg-$(VERSION_WORD).pk3

MOD = promod

all: $(GT_PK3)

$(GT_PK3): $(shell find gametype/)
	rm -rf temp
	mkdir temp
	rm -f *.pk3
	cp -r gametype/* temp/
	cd temp; zip ../$(GT_PK3) -r -xi *
	rm -r temp

local:
	rm -f ~/.warsow-0.6/basewsw/hgg-*.pk3
	rm -f ~/.warsow-0.6/$(MOD)/configs/server/gametypes/hgg_*.cfg
	cp $(GT_PK3) ~/.warsow-0.6/basewsw/

dev: all local
	wsw-server

.PHONY: all local dev
