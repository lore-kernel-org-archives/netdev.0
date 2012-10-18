From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 15:09:04 +0200
Message-ID: <m3mwzk3p1r.fsf@ursa.amorsen.dk>
References: <507F38D4.102@genband.com> <m3vce83w1y.fsf@ursa.amorsen.dk>
	<alpine.DEB.2.00.1210181458560.21297@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.ipvision.dk ([94.127.49.3]:57018 "EHLO gate2.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428Ab2JRNJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 09:09:16 -0400
In-Reply-To: <alpine.DEB.2.00.1210181458560.21297@uplift.swm.pp.se> (Mikael
	Abrahamsson's message of "Thu, 18 Oct 2012 15:00:01 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Abrahamsson <swmike@swm.pp.se> writes:

> Would you mind if it was user configurable?

No, I would not mind. But I am the wrong person to ask that question, I
do not have to deal with supporting configuration options.

> Would you mind if the TCP retransmit timers were severely lowered upon
> reconnection so your TCP sessions started working quicker? Or you
> don't see this problem at all?

I would not mind that at all. I do not particularly recall seeing the
problem, but that sounds like a great idea.


/Benny
