From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: smsc9420: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:43:54 -0700 (PDT)
Message-ID: <20160715.164354.1586317943137799646.davem@davemloft.net>
References: <1468571781-11136-1-git-send-email-tremyfr@gmail.com>
	<1468571781-11136-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468571781-11136-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 10:36:21 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
