From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: constify xgene_cle_ops structure
Date: Tue, 03 May 2016 13:03:16 -0400 (EDT)
Message-ID: <20160503.130316.1835415809247008167.davem@davemloft.net>
References: <1462106189-14277-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kernel-janitors@vger.kernel.org,
	kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462106189-14277-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  1 May 2016 14:36:28 +0200

> The xgene_cle_ops structure is never modified, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
