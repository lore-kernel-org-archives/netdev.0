From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 05 Nov 2008 01:34:39 -0800 (PST)
Message-ID: <20081105.013439.145121376.davem@davemloft.net>
References: <1225868744.31605.12.camel@localhost.localdomain>
	<20081104.233313.109709104.davem@davemloft.net>
	<1225877427.29712.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbYKEJfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:35:03 -0500
In-Reply-To: <1225877427.29712.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Wed, 05 Nov 2008 10:30:27 +0100

> I can trick the bug by simply doing a 'ping -A' from the host it
> self.

I can't reproduce here, sorry.

There must be something unique about your card or system.

I won't have time to dig more deeply into this until
next week some time.  View this as an excellent opportunity
for you to lean how the chip and the driver works yourself
and to start trying to dump TX ring chip information when
the hang occurs. :-)
