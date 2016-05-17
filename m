From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: ftgmac100: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 21:52:11 -0400 (EDT)
Message-ID: <20160516.215211.1900422975605026545.davem@davemloft.net>
References: <1463355314-20889-1-git-send-email-tremyfr@gmail.com>
	<1463355314-20889-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, linux@roeck-us.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463355314-20889-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 16 May 2016 01:35:14 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
