From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/27] drivers/net: Use memdup_user
Date: Mon, 31 May 2010 00:30:38 -0700 (PDT)
Message-ID: <20100531.003038.59657905.davem@davemloft.net>
References: <Pine.LNX.4.64.1005221018350.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005221018350.13021@ask.diku.dk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 22 May 2010 10:18:59 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Use memdup_user when user data is immediately copied into the
> allocated region.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ..
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
