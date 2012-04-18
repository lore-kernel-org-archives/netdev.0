From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/wan/farsync.c: add missing iounmap
Date: Tue, 17 Apr 2012 22:33:07 -0400 (EDT)
Message-ID: <20120417.223307.693772402010148380.davem@davemloft.net>
References: <1334589732-25876-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334589732-25876-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 16 Apr 2012 17:22:12 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Free card->mem in the error-handling code since it was successfully
> allocated just above.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks Julia.
