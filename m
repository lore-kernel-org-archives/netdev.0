From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 13:19:53 -0800 (PST)
Message-ID: <20110111.131953.180400101.davem@davemloft.net>
References: <1294779020.16410.2.camel@wall-e>
	<20110111.125254.133402589.davem@davemloft.net>
	<1294780480.17388.2.camel@wall-e>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, jj@chaosbits.net, daniel.baluta@gmail.com,
	jochen@jochen.org, hagen@jauu.net, torvalds@linux-foundation.org,
	pavel@ucw.cz
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294780480.17388.2.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>
Date: Tue, 11 Jan 2011 22:14:40 +0100

> If nobody need it and no user in the near future out there, why should i
> implement this? That is dogmatic only!

It's a hard requirement, sorry.

And I want you to do it especially because it shows clearly how poor
your implementation is, with all of it's code duplication.

You'll need yet another copy of all of this code to support ipv6.

Please implement this properly, and in doing so the ipv6 support will
be very simple if not trivial.
