From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: bgmac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Wed, 22 Jun 2016 16:26:27 -0400 (EDT)
Message-ID: <20160622.162627.1288079059620028758.davem@davemloft.net>
References: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
	<1466368626-28985-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, zajec5@gmail.com,
	fabio.estevam@freescale.com, jkosina@suse.cz, andrew@lunn.ch,
	nbd@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466368626-28985-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 19 Jun 2016 22:37:06 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
