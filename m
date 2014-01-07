From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [v4] phylib: Support attaching to generic 10g
 driver
Date: Tue, 07 Jan 2014 00:56:07 -0500 (EST)
Message-ID: <20140107.005607.716747884959539511.davem@davemloft.net>
References: <1389060865-7143-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jg1.han@samsung.com, mugunthanvnm@ti.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Shaohui.Xie@freescale.com, afleming@gmail.com
To: shh.xie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389060865-7143-1-git-send-email-shh.xie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <shh.xie@gmail.com>
Date: Tue, 7 Jan 2014 10:14:25 +0800

> -static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> +int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  			     u32 flags, phy_interface_t interface)

Since you are changing where the open parenthesis is, you must reindent
the arguments on the second line so that they start exactly at the
first column after that openning parenthesis.
