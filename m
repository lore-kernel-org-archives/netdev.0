From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: fix the rxdesc pointer when rx descriptor
 empty happens
Date: Tue, 29 May 2012 17:23:07 -0400 (EDT)
Message-ID: <20120529.172307.2230306328587848147.davem@davemloft.net>
References: <4FC491EB.4040002@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4FC491EB.4040002@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 29 May 2012 18:07:55 +0900

> When Receive Descriptor Empty happens, rxdesc pointer of the driver
> and actual next descriptor of the controller may be mismatch.
> This patch fixes it.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
