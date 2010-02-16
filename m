From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Tue, 16 Feb 2010 22:56:31 +0100
Message-ID: <m3635w4zg0.fsf@ursa.amorsen.dk>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	<1266160732-946-2-git-send-email-hadi@cyberus.ca>
	<4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	<4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	<m37hqdcvgm.fsf@ursa.amorsen.dk> <1266321437.6776.250.camel@bigi>
	<m3hbphxrnm.fsf@ursa.amorsen.dk> <1266326164.6776.263.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:44171 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933421Ab0BPV4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 16:56:46 -0500
In-Reply-To: <1266326164.6776.263.camel@bigi> (jamal's message of "Tue, 16 Feb
	2010 08:16:04 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> This is actually an interesting idea and is not far-fetched (and would
> certainly get rid of the replication problem). If i understood
> correctly, you would have:
> ip route add blah blah mark 0x10

Exactly.

> and that the routing core will use the mark to (as it does for example
> with ifindex) to pick the route? I like the idea for the simple fact it
> will reduce immensely configuration in some cases..

It would certainly be handy for me...


/Benny

