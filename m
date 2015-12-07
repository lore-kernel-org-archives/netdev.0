From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: constify hnae_buf_ops and hnae_ae_ops
 structures
Date: Sun, 06 Dec 2015 22:51:44 -0500 (EST)
Message-ID: <20151206.225144.1422377179689530868.davem@davemloft.net>
References: <1449419097-19032-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, huangdaode@hisilicon.com,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449419097-19032-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  6 Dec 2015 17:24:57 +0100

> The hnae_buf_ops and hnae_ae_ops structures are never modified, so declare
> them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

This doesn't apply to net-next.

> I have the impression that this driver is not recorded properly in the
> MAINTAINERS file.

Patches welcome.
