From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: constify xgene_mac_ops and
 xgene_port_ops structures
Date: Tue, 08 Dec 2015 21:39:45 -0500 (EST)
Message-ID: <20151208.213945.949354473613069832.davem@davemloft.net>
References: <1449605905-32342-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kernel-janitors@vger.kernel.org,
	kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449605905-32342-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue,  8 Dec 2015 21:18:25 +0100

> The xgene_mac_ops and xgene_port_ops structures are never modified, so
> declare them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks.
