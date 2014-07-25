From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: remove exceptional & on function name
Date: Thu, 24 Jul 2014 23:25:48 -0700 (PDT)
Message-ID: <20140724.232548.1008683510403341657.davem@davemloft.net>
References: <20140724202040.GA16310@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140724202040.GA16310@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 25 Jul 2014 01:50:41 +0530

> In this file, function names are otherwise used as pointers without &.
> 
> A simplified version of the Coccinelle semantic patch that makes this
> change is as follows: 
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
