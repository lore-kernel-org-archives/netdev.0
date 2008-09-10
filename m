From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
 feature-negotiation patches
Date: Tue, 09 Sep 2008 22:19:14 -0700 (PDT)
Message-ID: <20080909.221914.193697907.davem@davemloft.net>
References: <20080909115948.GA3551@gerrit.erg.abdn.ac.uk>
	<20080909.051546.193801654.davem@davemloft.net>
	<20080910050115.GA3642@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750859AbYIJFTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 01:19:20 -0400
In-Reply-To: <20080910050115.GA3642@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Sep 2008 07:01:15 +0200

> Not only are you lacking the courage to admit that it was your own fault
> to pull a tree no one had asked you to pull, now you are trying to make 
> me look foolish to cover your own mistake. 

Your subject line said, and it's still being used in this thread:
"net-next-2.6 [pull-request]"

What the heck should I take that to mean exactly?

> It further did not even occur to you to check the provided gitweb link, nor
> did you recognise that you had pulled about 100 instead of 37 patches. And
> you seem not to have looked at the diffstats either - what has a change in
> tcp_input.c got to do with a DCCP-only patch set?
>
> Not to mention the conflicts which you silently fixed instead of looking at
> their cause.

I did look at the merge conflicts I fixed up, code moved from one place
to another or got handled by new helper routines which were being
called, so I picked the appropriate hunk and validated the build.

If I wasn't all that sure of the result I would have replied to you
instead saying "this tree is messed up, I'm not pulling"  And I do
that all the time.

The shorter answer is I did my best and I TRUSTED YOU to only point
a GIT URL my way that was explicitly ready.  Else, you'd say "don't
pull this" rather than have "net-next-2.6 pull request" in the subject
line.

> What you are saying here has little authority. It is just foolish vanity.

Gerrit, it's over.  The only one in vain is you.
