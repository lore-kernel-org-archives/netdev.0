From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] net: sh_eth: add set_mdio_gate in bb_info
Date: Mon, 14 Mar 2011 14:11:17 -0700 (PDT)
Message-ID: <20110314.141117.246516850.davem@davemloft.net>
References: <4D75E1FB.6000607@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4D75E1FB.6000607@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 08 Mar 2011 16:59:55 +0900

> The SH7757's ETHER and GETHER use common MDIO pin. The MDIO pin is
> selected by specific register. So this patch adds new interface in
> bb_info, and when the sh_eth driver use the mdio, the register can
> be changed by the function.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
