From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: eth: altera: Change access ports to mdio for
 all xMII applications
Date: Thu, 19 Feb 2015 15:24:01 -0500 (EST)
Message-ID: <20150219.152401.649236797449579465.davem@davemloft.net>
References: <1423759653-5023-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com,
	kailng@altera.com, dwesterg@gmail.com
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423759653-5023-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Thu, 12 Feb 2015 10:47:33 -0600

> Change use of Altera TSE's MDIO access from phy 0 registers to phy 1
> registers. This allows support for GMII, MII, RGMII, and SGMII
> designs where the external PHY is always accesible through
> Altera TSE's MDIO phy 1 registers and Altera's PCS is accessible
> through MDIO phy 0 registers for SGMII applications.
> 
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
> Tested-by: Kai Lin Ng <kailng@altera.com>
> Tested-by: Dalon Westergreen <dwesterg@gmail.com>

Applied to net-next.
