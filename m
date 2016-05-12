From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: micrel: Use MICREL_PHY_ID_MASK definition
Date: Thu, 12 May 2016 16:57:18 -0400 (EDT)
Message-ID: <20160512.165718.1295735147761042519.davem@davemloft.net>
References: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
	fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbcELU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:57:22 -0400
In-Reply-To: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 11 May 2016 17:02:05 -0300

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Replace the hardcoded mask 0x00fffff0 with MICREL_PHY_ID_MASK for
> better readability.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied.
