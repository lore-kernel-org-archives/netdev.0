From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] r6040: check PHY status when bringing interface up
Date: Thu, 08 Jan 2009 11:02:06 -0800 (PST)
Message-ID: <20090108.110206.86756124.davem@davemloft.net>
References: <200901071740.38060.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759914AbZAHTCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:02:05 -0500
In-Reply-To: <200901071740.38060.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 7 Jan 2009 17:40:37 +0100

> r6040: check PHY status when bringing interface up
> 
> This patch makes the driver properly initialize the PHY
> status if not correctly set by the bootloader/BIOS.
> It prevents some boards to bring up the link on boot.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
