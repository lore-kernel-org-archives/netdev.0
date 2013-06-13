From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 15:59:21 +0200
Message-ID: <20130613135921.GA22906@linux-mips.org>
References: <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
 <20130613.022524.568792627006552244.davem@davemloft.net>
 <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
 <20130613.025619.2170890039313059326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: florian@openwrt.org, netdev@vger.kernel.org, blogic@openwrt.org,
	linux-mips@linux-mips.org, mbizon@freebox.fr, jogo@openwrt.org,
	cernekee@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:33719 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab3FMN7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 09:59:33 -0400
Received: from localhost.localdomain ([127.0.0.1]:56900 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6835138Ab3FMN7b7ILsu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jun 2013 15:59:31 +0200
Content-Disposition: inline
In-Reply-To: <20130613.025619.2170890039313059326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 02:56:19AM -0700, David Miller wrote:

> From: Florian Fainelli <florian@openwrt.org>
> Date: Thu, 13 Jun 2013 10:49:18 +0100
> 
> > We are in the slow process to switch to Device Tree to precisely
> > eliminate all of this (although not everyone agrees yet on the
> > details). Hopefully you should not see such things in the future.
> 
> Fair enough, I'll put this patch back into my TODO queue.

David is right, one pair of welding goggles isn't enough to cope with the
uglyness of this but as a temporary thing I can live with it, so

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Dave, feel free to merge this through next-next.  I'm going to drop
this patch from the MIPS patchwork then.

  Ralf
