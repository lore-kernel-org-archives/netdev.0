From: David Miller <davem@davemloft.net>
Subject: Re: Should ICMP echo responses be 'bound to the interface' of the
 incoming ICMP echo request?
Date: Thu, 07 Apr 2011 19:44:20 -0700 (PDT)
Message-ID: <20110407.194420.193709030.davem@davemloft.net>
References: <459953.12714.qm@web56602.mail.re3.yahoo.com>
	<alpine.DEB.2.00.1104080301280.14027@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iubica2@yahoo.com, ketil@froyn.name, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: swmike@swm.pp.se
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1104080301280.14027@uplift.swm.pp.se>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikael Abrahamsson <swmike@swm.pp.se>
Date: Fri, 8 Apr 2011 03:02:53 +0200 (CEST)

> On Thu, 7 Apr 2011, andrei radulescu-banu wrote:
> 
>> But here's a problem: the kernel supports only up to 256 route
>> domains, and I'd like to be able to use more interfaces than that,
>> physical plus virtual.
> 
> Sounds like that 256 limit should be the thing to be looked into then.

That limit was removed ages ago.

I notice that when discussions occur on this list, a lot of misinformation
gets spread around.

The problem is that the actual networking developers don't read this list,
they read netdev@vger.kernel.org instead.

Maybe it's time that we just get rid of linux-net because it's been nothing
but problematic as users search for information on it and very few people
on that list are knowledgable enough to even consider answering.

