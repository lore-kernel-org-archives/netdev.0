From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Tue, 16 Feb 2016 15:17:53 -0500 (EST)
Message-ID: <20160216.151753.1716747496918972138.davem@davemloft.net>
References: <1454962873-1941-1-git-send-email-bernhard@bwalle.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bernhard@bwalle.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454962873-1941-1-git-send-email-bernhard@bwalle.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Walle <bernhard@bwalle.de>
Date: Mon,  8 Feb 2016 21:21:13 +0100

> We need that for a custom hardware that needs the reverse reset
> sequence.
> 
> Signed-off-by: Bernhard Walle <bernhard@bwalle.de>

Applied to net-next, thanks.
