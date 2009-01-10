From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] r6040: fix ifconfig down and freeing of tx/rx
 descriptors
Date: Fri, 09 Jan 2009 23:07:07 -0800 (PST)
Message-ID: <20090109.230707.252449247.davem@davemloft.net>
References: <200901090204.39930.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, Joe.Chou@rdc.com.tw
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751674AbZAJHHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:07:06 -0500
In-Reply-To: <200901090204.39930.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 9 Jan 2009 02:04:39 +0100

> Subject: [PATCH 1/4] r6040: fix ifconfig down and freeing of tx/rx descriptors
> 
> This patch fixes warnings and such traces that appear when doing
> an ifconfig down on the interface:
> 
> WARNING: at arch/x86/kernel/pci-dma.c:376 dma_free_coherent+0x40/0x7d()
> Modules linked in:
> 
> Signed-off-by: Joe Chou <joe.chou@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
