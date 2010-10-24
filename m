From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Don't re-enable interrupts while in polling mode
Date: Sun, 24 Oct 2010 15:23:06 -0700 (PDT)
Message-ID: <20101024.152306.48512783.davem@davemloft.net>
References: <C8F551D39A7C724E987CF8DD11D3178304D02F88@svr3.sixnetio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, jpirko@redhat.com,
	peter.korsgaard@barco.com, eric.dumazet@gmail.com,
	haavard.skinnemoen@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Joshua.Hoke@sixnet.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C8F551D39A7C724E987CF8DD11D3178304D02F88@svr3.sixnetio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Joshua Hoke" <Joshua.Hoke@sixnet.com>
Date: Tue, 19 Oct 2010 12:48:22 -0400

> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index ff2f158..36cf594 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -515,14 +515,15 @@ static int macb_poll(struct napi_struct *napi, int
> budget)

Your email client is breaking up long lines which corrupts the
patch.

Please fix this up in your email client and resubmit.

Thank you.
