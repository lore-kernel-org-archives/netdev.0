From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked
 mode
Date: Wed, 24 Feb 2010 17:38:11 -0800 (PST)
Message-ID: <20100224.173811.264809559.davem@davemloft.net>
References: <20100224185340.GB15380@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
	<20100224211507.GC15380@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758737Ab0BYBhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 20:37:53 -0500
In-Reply-To: <20100224211507.GC15380@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 24 Feb 2010 16:15:07 -0500

> Looking at the 1.7.6 tarball on sourceforge, its dated 10/10/2008,
> so you've basically got a 1.5 year lag between the development
> version and the commited version that distributions are using (and
> counting).  I'm sorry, I'm not trying to be crass about this, but
> its rather disconcerting to see that kind of discrepancy between the
> code development point and whats in net-next.  It implies that the
> only fix for a tipc problem is a wholesale upgrade of the tipc
> directory in the kernel (since it would seem the sourceforge tipc
> cvs tree has gone unused for a few years).

I'm extremely upset about this.

Especially given the fact that EVERY DAMN TIME there were TIPC
patches posted I applied EVERY DAMN ONE of them, and I did so
in an expediant manner.

So there is zero reason for the TIPC protocol development to not have
occured upstream.  I, in fact, facilitated things to work that way in
the smoothest way possible, if only the TIPC developers had obliged.
