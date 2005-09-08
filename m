From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Fri, 09 Sep 2005 01:12:21 +0200
Message-ID: <4320C555.4020800@tpack.net>
References: <200509080125.j881PcL9015847@hera.kernel.org>	<431F9899.4060602@pobox.com>	<Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>	<1126184700.4805.32.camel@tsc-6.cph.tpack.net>	<Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>	<1126190554.4805.68.camel@tsc-6.cph.tpack.net>	<Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de>	<4320BD96.3060307@tpack.net> <20050908154114.69307f92.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bogdan.Costescu@iwr.uni-heidelberg.de, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965071AbVIHXKE@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050908154114.69307f92.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Should we also decrease the polling interval?  Perhaps only when the cable
> is unplugged?

Sounds like a plan. 60 seconds certainly strikes me as being very slow.
OTOH, I'm not aware of the reasoning behind this choice in the first place.
It might make sense for some odd setups.

Since I don't even have any HW to play around with, I think I'll step
down for now.


-Tommy
