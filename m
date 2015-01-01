From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] net: sun4i-emac: fix error return code
Date: Wed, 31 Dec 2014 19:20:00 -0500 (EST)
Message-ID: <20141231.192000.244752729516752388.davem@davemloft.net>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419872683-32709-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxime.ripard@free-electrons.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 29 Dec 2014 18:04:40 +0100

> Return a negative error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
