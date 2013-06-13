From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 02:56:19 -0700 (PDT)
Message-ID: <20130613.025619.2170890039313059326.davem@davemloft.net>
References: <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
	<20130613.022524.568792627006552244.davem@davemloft.net>
	<CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, blogic@openwrt.org,
	linux-mips@linux-mips.org, mbizon@freebox.fr, jogo@openwrt.org,
	cernekee@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758552Ab3FMJ4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:56:20 -0400
In-Reply-To: <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Thu, 13 Jun 2013 10:49:18 +0100

> We are in the slow process to switch to Device Tree to precisely
> eliminate all of this (although not everyone agrees yet on the
> details). Hopefully you should not see such things in the future.

Fair enough, I'll put this patch back into my TODO queue.
