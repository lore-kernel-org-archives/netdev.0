From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 21:16:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam> <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se> <4DAC8A8A.1010401@cox.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:38718 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab1DRTQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 15:16:36 -0400
In-Reply-To: <4DAC8A8A.1010401@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011, Joe Buehler wrote:

> The argument I have seen for not making reflection standard behavior is 
> that it is not always appropriate for the application.  For example, web 
> servers have short requests but large responses so non-identical DSCP 
> values might make more sense.

I'm a router guy. I don't understand this reasoning at all.

Anyone care to elaborate?

I'd like reflection be standard and have the application set DSCP if it 
needs to.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
