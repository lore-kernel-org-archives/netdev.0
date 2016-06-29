From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: mvpp2: use
 phy_ethtool_{get|set}_link_ksettings
Date: Wed, 29 Jun 2016 06:05:35 -0400 (EDT)
Message-ID: <20160629.060535.1405302756445494902.davem@davemloft.net>
References: <1467065292-20996-1-git-send-email-tremyfr@gmail.com>
	<1467065292-20996-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mw@semihalf.com, jszhang@marvell.com, amitoj1606@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467065292-20996-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 28 Jun 2016 00:08:12 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
