From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: dwc_eth_qos: use
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 28 Jun 2016 09:22:43 -0400 (EDT)
Message-ID: <20160628.092243.779722280947708745.davem@davemloft.net>
References: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
	<1466888716-31222-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466888716-31222-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 25 Jun 2016 23:05:16 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
