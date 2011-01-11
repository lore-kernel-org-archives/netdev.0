From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 12:52:54 -0800 (PST)
Message-ID: <20110111.125254.133402589.davem@davemloft.net>
References: <1294764515-15356-1-git-send-email-stefani@seibold.net>
	<1294765273.2927.65.camel@edumazet-laptop>
	<1294779020.16410.2.camel@wall-e>
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
In-Reply-To: <1294779020.16410.2.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>
Date: Tue, 11 Jan 2011 21:50:20 +0100

> Right, but currently there is no need for an IPV6 implementation, non of
> our base station provide it and non of our mobile network customers use
> it.
> 
> If it will be required in the future it will be implemented.

We require that you implement the ipv6 side for the submission right
now.

Long gone are the days when we add ipv4 only implementations of
protocols.
