From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xt_hashlimit: fix locking
Date: Wed, 17 Feb 2010 13:39:04 -0800 (PST)
Message-ID: <20100217.133904.176439942.davem@davemloft.net>
References: <20100216145550.2796.32.sendpatchset@x2.localnet>
	<1266425027.3075.66.camel@edumazet-laptop>
	<4B7C4CD1.1070105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7C4CD1.1070105@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 17 Feb 2010 21:08:49 +0100

> Eric Dumazet wrote:
>> Or following quick & dirty patch just cures the problem.
> 
> Thanks, this looks fine.

To get this fixed quickly I've applied this directly
to net-next-2.6, thanks everyone.
