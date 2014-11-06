From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: slave: Fix autoneg for phys on switch MDIO
 bus
Date: Thu, 06 Nov 2014 15:06:42 -0500 (EST)
Message-ID: <20141106.150642.550801552869655156.davem@davemloft.net>
References: <1415213248-29037-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaKFUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:06:44 -0500
In-Reply-To: <1415213248-29037-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  5 Nov 2014 19:47:28 +0100

> When the ports phys are connected to the switches internal MDIO bus,
> we need to connect the phy to the slave netdev, otherwise
> auto-negotiation etc, does not work.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
