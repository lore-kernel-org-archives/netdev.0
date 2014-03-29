From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy/at8031: enable at8031 to work on interrupt mode
Date: Sat, 29 Mar 2014 18:20:54 -0400 (EDT)
Message-ID: <20140329.182054.1947915200276978934.davem@davemloft.net>
References: <1395992381-23094-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	B07421@freescale.com, linux-kernel@vger.kernel.org,
	mugunthanvnm@ti.com, zonque@gmail.com, helmut.schaa@googlemail.com,
	R63061@freescale.com
To: B45475@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395992381-23094-1-git-send-email-B45475@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Qiang <B45475@freescale.com>
Date: Fri, 28 Mar 2014 15:39:41 +0800

> The at8031 can work on polling mode and interrupt mode.
> Add ack_interrupt and config intr funcs to enable
> interrupt mode for it.
> 
> Signed-off-by: Zhao Qiang <B45475@freescale.com>
> ---
> changes for v2:
> 	- when interrupt is not enabled, write 0 to interrupt enbale register
> 	- delete a inner parens not needed

Applied to net-next, thanks.
