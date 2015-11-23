From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atm: constify in_cache_ops and eg_cache_ops
 structures
Date: Mon, 23 Nov 2015 15:49:39 -0500 (EST)
Message-ID: <20151123.154939.938227313695257772.davem@davemloft.net>
References: <1448126885-7666-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448126885-7666-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 21 Nov 2015 18:28:05 +0100

> The in_cache_ops and eg_cache_ops structures are never modified, so declare
> them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
