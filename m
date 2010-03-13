From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/tg3.c: change the field used with the
 TG3_FLAG_10_100_ONLY constant
Date: Sat, 13 Mar 2010 12:22:26 -0800 (PST)
Message-ID: <20100313.122226.91435148.davem@davemloft.net>
References: <Pine.LNX.4.64.1003131000420.30245@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1003131000420.30245@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 13 Mar 2010 10:01:09 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> The constant TG3_FLAG_10_100_ONLY should be used with the tg3_flags field,
> not the tg3_flags2 field, as done elsewhere in the same file.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks a lot Julia.
