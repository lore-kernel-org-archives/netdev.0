From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 12 (benet/be2net)
Date: Fri, 12 Aug 2011 23:19:09 -0700 (PDT)
Message-ID: <20110812.231909.939460841377364522.davem@davemloft.net>
References: <20110812171311.4d7bb640f38838bf7c34df50@canb.auug.org.au>
	<20110812135618.a209d9af.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110812135618.a209d9af.rdunlap@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 12 Aug 2011 13:56:18 -0700

> On Fri, 12 Aug 2011 17:13:11 +1000 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> [The kernel.org mirroring is being very slow today]
> 
>   [s.l.o.w.]
>  
>> The net tree gained a build failure do I used the version from
>> next-20110811.
> 
> 
> On i386:
> 
> drivers/built-in.o: In function `be_rx_eqd_update':
> be_main.c:(.text+0x569229): undefined reference to `__udivdi3'

This is fixed in the net-next tree already by Eric Dumazet, but
thanks for reporting. :-)
