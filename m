From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers/net/ethernet/tundra/tsi108_eth.c: delete
 double assignment
Date: Thu, 30 Aug 2012 13:09:10 -0400 (EDT)
Message-ID: <20120830.130910.1673588383256719426.davem@davemloft.net>
References: <1345969115-12977-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345969115-12977-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 26 Aug 2012 10:18:35 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Delete successive assignments to the same location.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks Julia.
