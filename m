From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: lantiq_etop: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 04 Jul 2016 16:01:23 -0700 (PDT)
Message-ID: <20160704.160123.2215962863662143310.davem@davemloft.net>
References: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
	<1467497105-19935-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, sudipm.mukherjee@gmail.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467497105-19935-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  3 Jul 2016 00:05:05 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
