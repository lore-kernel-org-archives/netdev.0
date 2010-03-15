From: David Miller <davem@davemloft.net>
Subject: Re: [1/3] gigaset: avoid registering CAPI driver more than once
Date: Mon, 15 Mar 2010 14:20:40 -0700 (PDT)
Message-ID: <20100315.142040.58983190.davem@davemloft.net>
References: <1268664986.25524@pingi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, hjlipp@web.de,
	i4ldeveloper@listserv.isdn4linux.de
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268664986.25524@pingi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Karsten the way you reforward patches does not work.

And I've told you about this last time you submitted ISDN patches.

You don't add an extra "From: " line in the message body, so when the
patch gets applied the author gets set to _you_ instead of the person
who actually wrote the change.

All you're doing is ACK'ing this person's work, so simply reply to the
patch they posted and with your "Acked-by" line.  This way patchwork
and friends will figure out the rest when the patch gets integrated
into the net-2.6 tree.

By reposting the patches the way you are we're losing information.

Add to this the fact that you never have the time to properly take
care of ISDN patches, and when you do finally "get to it" you make all
kinds of submission errors.

This is not the first time either, it happens over and over again.
It's incredibly frustrating, especially for me.

Please seriously consider handing ISDN maintainership over to someone
who unlike you 1) has the time and the desire and 2) knows how to
submit patches properly.  Probably Tilman is the person who most meets
these criteria based upon what I've seen.

Meanwhile, I'm going to apply the original patches as posted by
Tilman so that the proper authorship gets set.
