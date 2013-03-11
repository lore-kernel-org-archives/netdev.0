From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/2] phy/micrel: Add support for KSZ8031
Date: Mon, 11 Mar 2013 13:39:46 +0100
Message-ID: <201303111339.46507.marex@denx.de>
References: <1362991803-4610-1-git-send-email-hector.palacios@digi.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362991803-4610-1-git-send-email-hector.palacios@digi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Hector Palacios,

> Micrel PHY KSZ8031 is similar to KSZ8021 and also requires the special
> initialization of "Operation Mode Strap Override" in reg 0x16
> introduced in 212ea99 (phy/micrel: Implement support for KSZ8021).
> 
> Signed-off-by: Hector Palacios <hector.palacios@digi.com>

I dont have any board with this one, yet I think this change is correct, so:

Reviewed-by: Marek Vasut <marex@denx.de>

Best regards,
Marek Vasut
