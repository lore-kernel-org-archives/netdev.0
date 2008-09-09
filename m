From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
 feature-negotiation patches
Date: Tue, 09 Sep 2008 05:15:46 -0700 (PDT)
Message-ID: <20080909.051546.193801654.davem@davemloft.net>
References: <20080909080911.GA9176@gerrit.erg.abdn.ac.uk>
	<20080909.015720.204027435.davem@davemloft.net>
	<20080909115948.GA3551@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbYIIMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:15:53 -0400
In-Reply-To: <20080909115948.GA3551@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 9 Sep 2008 13:59:48 +0200

> Let's keep this clean and simple. There has been a mistake here and it
> needs to be fixed. It does not help to argue loudly whose fault it was.
> 
> Please consider pulling from
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	 [subtree `master']
> 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=summary
> 
> where I have reverted the pull and compile-tested the result. 

I hate to have a turd like this in the history, but fine I pulled this :-/

I may have to rebase net-next-2.6 after all, this is revoltingly ugly...

This is exactly what I didn't want Gerrit, a royally screwed up GIT
history because of the mistake.  It's WORSE now with the revert.
Can't you see that?  That's why I asked for fixup changesets, rather
than a revert.

I would have rather you sent me a small set of fixup patches that
cured whatever problems were in those changes.  That would have shown
the development history.

Now we're just going to have crap.  A large set of changes going in, then
one huge revert, and nobody will ever get to see exactly what happened
in between.

I've had enough.

I'd like to get the DCCP changes through someone else, please.
Someone willing to learn to use GIT properly.  Someone who understands
how important it is to keep the GIT history clean and not put a lot of
noise into the tree.  Someone who has the time to do this right and I
can trust.
