From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 17:22:37 -0700 (PDT)
Message-ID: <20130613.172237.1405190894345298627.davem@davemloft.net>
References: <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
	<20130613.025619.2170890039313059326.davem@davemloft.net>
	<20130613135921.GA22906@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org, blogic@openwrt.org,
	linux-mips@linux-mips.org, mbizon@freebox.fr, jogo@openwrt.org,
	cernekee@gmail.com
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759232Ab3FNAWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:22:39 -0400
In-Reply-To: <20130613135921.GA22906@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 13 Jun 2013 15:59:21 +0200

> On Thu, Jun 13, 2013 at 02:56:19AM -0700, David Miller wrote:
> 
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Thu, 13 Jun 2013 10:49:18 +0100
>> 
>> > We are in the slow process to switch to Device Tree to precisely
>> > eliminate all of this (although not everyone agrees yet on the
>> > details). Hopefully you should not see such things in the future.
>> 
>> Fair enough, I'll put this patch back into my TODO queue.
> 
> David is right, one pair of welding goggles isn't enough to cope with the
> uglyness of this but as a temporary thing I can live with it, so
> 
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
> 
> Dave, feel free to merge this through next-next.  I'm going to drop
> this patch from the MIPS patchwork then.

Applied to net-next, thanks everyone.
