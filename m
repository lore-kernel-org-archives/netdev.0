From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: sun4i-emac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Wed, 22 Jun 2016 16:25:52 -0400 (EDT)
Message-ID: <20160622.162552.1263761804213726339.davem@davemloft.net>
References: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
	<1466255740-20999-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxime.ripard@free-electrons.com, wens@csie.org,
	hdegoede@redhat.com, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466255740-20999-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 15:15:40 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
