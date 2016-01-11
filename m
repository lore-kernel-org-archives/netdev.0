From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: amd: au1000: Remove pointless
 warning
Date: Sun, 10 Jan 2016 22:07:31 -0500 (EST)
Message-ID: <20160110.220731.562630335571441579.davem@davemloft.net>
References: <1452471201-26335-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758080AbcAKDHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:07:33 -0500
In-Reply-To: <1452471201-26335-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 11 Jan 2016 01:13:21 +0100

> The warning about being able to read any MDIO device, not just the
> attached ethernet devices PHY applies to all MDIO drivers. So remove
> it. This also removes a reference to a member in phy_device which has
> moved.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
