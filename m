From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r6040: check and update media status
Date: Wed, 27 May 2009 15:49:44 -0700 (PDT)
Message-ID: <20090527.154944.30157459.davem@davemloft.net>
References: <200905271138.11348.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757128AbZE0Wtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 18:49:45 -0400
In-Reply-To: <200905271138.11348.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 27 May 2009 11:38:10 +0200

> Subject: [PATCH -next] r6040: check and update media status
> 
> This patch removes the not-that-useful message in the
> r6040_timer which prints the PHY status. Instead
> replace it with a call to mii_check_media which will
> update the link status and print it on startup.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
