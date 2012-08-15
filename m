From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] drivers/net/ethernet/freescale/fs_enet: fix error
 return code
Date: Tue, 14 Aug 2012 17:01:09 -0700 (PDT)
Message-ID: <20120814.170109.2145761320842984364.davem@davemloft.net>
References: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
	<1344949115-13266-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, kernel-janitors@vger.kernel.org,
	vbordug@ru.mvista.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344949115-13266-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 14 Aug 2012 14:58:33 +0200

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
