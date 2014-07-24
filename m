From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH net.git] net: Fix recvmmsg timeout handling
Date: Thu, 24 Jul 2014 12:45:57 -0300
Message-ID: <20140724154557.GE7831@kernel.org>
References: <20140721192131.GA3212@kernel.org>
 <20140721.204538.1952841990990568877.davem@davemloft.net>
 <20140722194851.GG20303@kernel.org>
 <20140723.145124.1007842943001121868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages@gmail.com, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:47176 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759268AbaGXPqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 11:46:01 -0400
Content-Disposition: inline
In-Reply-To: <20140723.145124.1007842943001121868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Jul 23, 2014 at 02:51:24PM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@kernel.org>
> Date: Tue, 22 Jul 2014 16:48:51 -0300
> > Em Mon, Jul 21, 2014 at 08:45:38PM -0700, David Miller escreveu:
> >> From: Arnaldo Carvalho de Melo <acme@kernel.org>
> >> Date: Mon, 21 Jul 2014 16:21:31 -0300

> >> > 	Trying to get this merged, finally. I has whas has been
> >> > discussed so far and agreed wrt the timeout handling.
 
> >> This gets lots of rejects against the current 'net' tree.
 
> >> Please respin and integrate Remi's Acked-by, thanks.
 
> > Here it is, I think we should wait a bit till Michael (and whoever else
> > is up to test this today) can test it, Michael?

> I don't see any testing feedback yet.

:-\
 
> Also, Arnaldo, if you could submit patches in the standard way
> that would help me a lot.  Subject line is fine, but you're then
> just inserting the output of something like "git show" into the
> email body.

/me stands corrected, should've know better.

I'll wait some more time and then resubmit, doing the whole process
myself so that it works in the standard way, git-am, etc.

- Arnaldo
