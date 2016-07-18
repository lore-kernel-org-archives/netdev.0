From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: marvell: pxa168_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 17 Jul 2016 23:23:01 -0700 (PDT)
Message-ID: <20160717.232301.73413260889276891.davem@davemloft.net>
References: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
	<1468791046-19567-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jszhang@marvell.com, sergei.shtylyov@cogentembedded.com,
	mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468791046-19567-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 17 Jul 2016 23:30:46 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
