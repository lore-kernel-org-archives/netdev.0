From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Thu, 24 Nov 2011 20:06:50 -0500
Message-ID: <20111124200650.c1f609ef.billfink@mindspring.com>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	<1322172898.2872.7.camel@edumazet-laptop>
	<20111124223118.GH2673@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:45947
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752140Ab1KYBQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 20:16:27 -0500
In-Reply-To: <20111124223118.GH2673@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Nov 2011, Hagen Paul Pfeifer wrote:

> * Eric Dumazet | 2011-11-24 23:14:58 [+0100]:
> 
> >Only point is why you chose ratelatency instead of rate ?
> 
> 
> Not sure why, it was called rate in v1, then somebody said ratelatency and I
> found it more stating. So in v2 it become ratelatency. I have no strong
> opinion here - should I generate v3?

>From the user perspective, I also find rate much more natural.
No need to add further to tc obscurity.

I would ask for an update to the netem man page, but I guess
there isn't a netem man page.  :-(

					-Bill
