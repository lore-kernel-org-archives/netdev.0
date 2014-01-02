From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/25] net: fix error return code
Date: Thu, 02 Jan 2014 03:31:28 -0500 (EST)
Message-ID: <20140102.033128.1126194974741927303.davem@davemloft.net>
References: <1388357260-4843-1-git-send-email-Julia.Lawall@lip6.fr>
	<1388357260-4843-8-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geoff@infradead.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1388357260-4843-8-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 29 Dec 2013 23:47:22 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Set the return variable to propagate any error code as done elsewhere in
> the function.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
