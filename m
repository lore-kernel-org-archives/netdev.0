From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/16] net/ax25: Use available error codes
Date: Wed, 18 Aug 2010 14:28:20 -0700 (PDT)
Message-ID: <20100818.142820.260103905.davem@davemloft.net>
References: <Pine.LNX.4.64.1008161826390.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1008161826390.19313@ask.diku.dk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Mon, 16 Aug 2010 18:26:57 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Error codes are stored in err, but the return value is always 0.  Return
> err instead.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
