From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/27] drivers/net/wan: Use memdup_user
Date: Mon, 31 May 2010 00:31:19 -0700 (PDT)
Message-ID: <20100531.003119.246507627.davem@davemloft.net>
References: <Pine.LNX.4.64.1005221025450.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005221025450.13021@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 22 May 2010 10:26:04 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Use memdup_user when user data is immediately copied into the
> allocated region.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
