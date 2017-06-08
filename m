From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: ti: cpdma: do not enable host
 error misc irq
Date: Thu, 08 Jun 2017 19:32:26 -0400 (EDT)
Message-ID: <20170608.193226.1216551479485033402.davem@davemloft.net>
References: <20170608185152.32710-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608185152.32710-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 8 Jun 2017 13:51:52 -0500

> CPSW driver does not handle this interrupt, so there are no reasons to enable
> it in hardware.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied.
