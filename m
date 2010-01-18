From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] drivers/net: Eliminate useless code
Date: Mon, 18 Jan 2010 00:29:31 -0800 (PST)
Message-ID: <20100118.002931.55279267.davem@davemloft.net>
References: <Pine.LNX.4.64.1001161657400.28745@ask.diku.dk>
	<20100117.193140.153138395.davem@davemloft.net>
	<Pine.LNX.4.64.1001180911080.12648@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755030Ab0ARI3Y@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1001180911080.12648@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Mon, 18 Jan 2010 09:12:21 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> The variable qdev is initialized twice to the same (side effect-free)
> expression.  Drop one initialization.
> 
> A simplified version of the semantic match that finds this problem is:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks.
