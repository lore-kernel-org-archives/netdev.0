From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: smsc: smsc911x: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 04 Jul 2016 16:01:34 -0700 (PDT)
Message-ID: <20160704.160134.1921548044410459136.davem@davemloft.net>
References: <1467501261-8839-1-git-send-email-tremyfr@gmail.com>
	<1467501261-8839-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467501261-8839-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  3 Jul 2016 01:14:21 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
