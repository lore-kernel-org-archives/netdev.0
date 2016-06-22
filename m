From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: altera_tse: use
 phy_ethtool_{get|set}_link_ksettings
Date: Wed, 22 Jun 2016 16:26:08 -0400 (EDT)
Message-ID: <20160622.162608.627519168922893203.davem@davemloft.net>
References: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
	<1466260641-22506-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466260641-22506-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 16:37:21 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
