From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] myri10ge: fix error return code
Date: Wed, 31 Dec 2014 19:20:26 -0500 (EST)
Message-ID: <20141231.192026.1227963371078197478.davem@davemloft.net>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419872683-32709-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hykim@myri.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 29 Dec 2014 18:04:37 +0100

> Return a negative error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
 The patch also modifies the test of mgp->cmd to satisfy checkpatch.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
