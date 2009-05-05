From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r6040: check for absent PHY
Date: Tue, 05 May 2009 12:30:18 -0700 (PDT)
Message-ID: <20090505.123018.165995177.davem@davemloft.net>
References: <200905050830.01683.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758198AbZEETaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 15:30:23 -0400
In-Reply-To: <200905050830.01683.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 5 May 2009 08:30:01 +0200

> Some devices have two R6040 MACs but the second one
> is not wired to any PHY, therefore the interface is
> just unusable. Warn the user about that and prevent
> device from registering.
> 
> Tested-by: bifferos <bifferos@yahoo.co.uk>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
