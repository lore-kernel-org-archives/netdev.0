From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 4/7] [CCID-3]: Fix "t_ipi explosion" bug
Date: Tue, 27 May 2008 15:16:37 +0100
Message-ID: <20080527141637.GB28240@gerrit.erg.abdn.ac.uk>
References: <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk> <1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk> <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk> <20080527.063533.185406813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40439 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754024AbYE0OQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 10:16:48 -0400
Content-Disposition: inline
In-Reply-To: <20080527.063533.185406813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 
| Because you're mixing coding style cleanups, both of which I've
| just NACK'd, with real bug fixes, you're making a lot of work for
| me.
|
I am sorry, but I was under the impression that you were busy already
and thus that the fixes would need to wait until net-next-2.6.

This was in part my fault and would have been avoidable, since I had
actually created both trees in parallel with the same set of patches:

	git://eden-feed.erg.abdn.ac.uk/net-2.6.git
	git://eden-feed.erg.abdn.ac.uk/net-next-2.6.git

I'd suggest to stop for now, I will resubmit the whole lot which
inevitably will need to be recoded.

Gerrit
