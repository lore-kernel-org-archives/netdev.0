From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1] phy: micrel: Fix finding PHY properties in MAC
 node for KSZ9031.
Date: Fri, 08 Jan 2016 21:49:08 -0500 (EST)
Message-ID: <20160108.214908.1776832581595314892.davem@davemloft.net>
References: <1452155475-7742-1-git-send-email-henri.roosen@ginzinger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch
To: henri.roosen@ginzinger.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452155475-7742-1-git-send-email-henri.roosen@ginzinger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henri Roosen <henri.roosen@ginzinger.com>
Date: Thu, 7 Jan 2016 09:31:15 +0100

> Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
>  node.") only fixes finding PHY properties in MAC node for KSZ9021. This
> commit applies the same fix for KSZ9031.
> 
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
> ---
> 
> Changes since v2:
>  - removed unnecessary empty line

Applied, thanks Henri.
