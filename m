From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] r6040: generate random ethernet MAC address when
 not initialized
Date: Fri, 09 Jan 2009 23:07:13 -0800 (PST)
Message-ID: <20090109.230713.187748981.davem@davemloft.net>
References: <200901090204.45766.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751782AbZAJHHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:07:12 -0500
In-Reply-To: <200901090204.45766.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 9 Jan 2009 02:04:45 +0100

> From: Florian Fainelli <florian@openwrt.org>
> Subject: [PATCH 2/4] r6040: generate random ethernet MAC address when not initialized
> 
> This patch makes the ethernet driver assign a random ethernet
> MAC address when the bootloader does not set it.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
