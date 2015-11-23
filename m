From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: constify vmci_transport_notify_ops structures
Date: Mon, 23 Nov 2015 15:49:46 -0500 (EST)
Message-ID: <20151123.154946.1373634995645161672.davem@davemloft.net>
References: <1448127557-22280-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, rjui@broadcom.com,
	sbranden@broadcom.com, jonmason@broadcom.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448127557-22280-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 21 Nov 2015 18:39:17 +0100

> The vmci_transport_notify_ops structures are never modified, so declare
> them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
