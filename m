From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: macb: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sat, 25 Jun 2016 11:58:01 -0400 (EDT)
Message-ID: <20160625.115801.127788695818617375.davem@davemloft.net>
References: <1466548356-19166-1-git-send-email-tremyfr@gmail.com>
	<1466548356-19166-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466548356-19166-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 22 Jun 2016 00:32:36 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
