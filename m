From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4 v2] net: sh_eth: remove unnecessary
 function
Date: Wed, 27 Jun 2012 01:24:41 -0700 (PDT)
Message-ID: <20120627.012441.627952479905212771.davem@davemloft.net>
References: <4FEAA157.9060403@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4FEAA157.9060403@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 27 Jun 2012 14:59:51 +0900

> The sh_eth_timer() called mod_timer() for itself. So, this patch
> removes the function.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
