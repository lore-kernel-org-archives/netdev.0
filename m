From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: constify vsock_transport structure
Date: Tue, 03 May 2016 13:03:23 -0400 (EDT)
Message-ID: <20160503.130323.1929865256655720740.davem@davemloft.net>
References: <1462106955-22131-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, rjui@broadcom.com,
	sbranden@broadcom.com, jonmason@broadcom.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1462106955-22131-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  1 May 2016 14:49:15 +0200

> The vsock_transport structure is never modified, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
