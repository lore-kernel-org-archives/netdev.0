From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: dp83848: Support ethernet pause frames
Date: Mon, 05 Dec 2016 13:14:08 -0500 (EST)
Message-ID: <20161205.131408.277804298653326225.davem@davemloft.net>
References: <20161202142203.GY19016@axis.com>
        <20161202145748.GA19016@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, rogerq@ti.com, afd@ti.com, dmurphy@ti.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jesper.nilsson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202145748.GA19016@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Fri, 2 Dec 2016 15:57:49 +0100

> According to the documentation, the PHYs supported by this driver
> can also support pause frames. Announce this to be so.
> Tested with a TI83822I.
> 
> Acked-by: Andrew F. Davis <afd@ti.com>
> Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>

Applied to net-next, thanks.
