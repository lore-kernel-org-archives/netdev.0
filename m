From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] drivers/net/ethernet/mellanox/mlx4/mcg.c: fix
 error return code
Date: Tue, 14 Aug 2012 17:01:19 -0700 (PDT)
Message-ID: <20120814.170119.1578623634371862790.davem@davemloft.net>
References: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
	<1344949115-13266-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344949115-13266-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 14 Aug 2012 14:58:34 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Convert a 0 error return code to a negative one, as returned elsewhere in the
> function.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
