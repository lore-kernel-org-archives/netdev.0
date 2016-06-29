From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: marvell: Add separate config ANEG function for
 Marvell 88E1111
Date: Wed, 29 Jun 2016 04:09:02 -0400 (EDT)
Message-ID: <20160629.040902.1424273572276962873.davem@davemloft.net>
References: <1467013199-26925-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, harinikatakamlinux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	harinik@xilinx.com, punnaia@xilinx.com, michals@xilinx.com
To: harini.katakam@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467013199-26925-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Mon, 27 Jun 2016 13:09:59 +0530

> Marvell 88E1111 currently uses the generic marvell config ANEG function.
> This function has a sequence accessing Page 5 and Register 31,
> both of which are not defined or reserved for this PHY.
> Hence this patch adds a new config ANEG function for Marvell 88E1111
> without these erroneous accesses.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>

Applied.
