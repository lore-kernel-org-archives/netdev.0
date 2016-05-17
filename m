From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: fec-mpc52xx: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 22:20:29 -0400 (EDT)
Message-ID: <20160516.222029.1073518763830483764.davem@davemloft.net>
References: <1463437954-6014-1-git-send-email-tremyfr@gmail.com>
	<1463437954-6014-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: treding@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463437954-6014-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 17 May 2016 00:32:34 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
