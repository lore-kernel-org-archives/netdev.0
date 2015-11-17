From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: marvell: Add support for 88E1540 PHY
Date: Tue, 17 Nov 2015 15:26:13 -0500 (EST)
Message-ID: <20151117.152613.1009186439336150306.davem@davemloft.net>
References: <1447713281-26069-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbKQU0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:26:15 -0500
In-Reply-To: <1447713281-26069-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 16 Nov 2015 23:34:41 +0100

> The 88E1540 can be found embedded in the Marvell 88E6352 switch.  It
> is compatible with the 88E1510, so add support for it, using the
> 88E1510 specific functions.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
