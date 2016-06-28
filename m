From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: dnet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 28 Jun 2016 05:12:25 -0400 (EDT)
Message-ID: <20160628.051225.46701963707196008.davem@davemloft.net>
References: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
	<1466718539-6526-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466718539-6526-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 23 Jun 2016 23:48:59 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
