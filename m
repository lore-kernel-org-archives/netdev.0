From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/3] net: sh_eth: use ioremap()
Date: Wed, 28 Sep 2011 13:43:29 -0400 (EDT)
Message-ID: <20110928.134329.208201561913485912.davem@redhat.com>
References: <4E82D16A.8090105@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E82D16A.8090105@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 28 Sep 2011 16:48:58 +0900

> This patch also changes writel/readl to iowrite32/ioread32.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
