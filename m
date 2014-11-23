From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] solos-pci: fix error return code
Date: Sun, 23 Nov 2014 14:30:16 -0500 (EST)
Message-ID: <20141123.143016.2013887575160072697.davem@davemloft.net>
References: <1416667159-9808-1-git-send-email-Julia.Lawall@lip6.fr>
	<1416667159-9808-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416667159-9808-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 22 Nov 2014 15:39:17 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Return a negative error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks Julia.
