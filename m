From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: ll_temac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Thu, 14 Jul 2016 17:43:06 -0700 (PDT)
Message-ID: <20160714.174306.915953817280918268.davem@davemloft.net>
References: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
	<1468453732-7370-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	andrew@lunn.ch, f.fainelli@gmail.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de, felipe.balbi@linux.intel.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468453732-7370-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 01:48:52 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
