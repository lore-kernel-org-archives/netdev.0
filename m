From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] net: Xilinx: fix error return code
Date: Wed, 31 Dec 2014 19:20:14 -0500 (EST)
Message-ID: <20141231.192014.628446769859477158.davem@davemloft.net>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419872683-32709-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, kernel-janitors@vger.kernel.org,
	soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 29 Dec 2014 18:04:36 +0100

> Return a negative error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
