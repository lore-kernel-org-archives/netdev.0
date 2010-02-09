From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/11] drivers/net: Correct NULL test
Date: Mon, 08 Feb 2010 22:44:59 -0800 (PST)
Message-ID: <20100208.224459.02579519.davem@davemloft.net>
References: <Pine.LNX.4.64.1002060943580.8092@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1002060943580.8092@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 6 Feb 2010 09:44:15 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> Test the value that was just allocated rather than the previously tested one.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)

Hehe, every time I read that tool name I hear "Coco Channel" :-)

> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks!
