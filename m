From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/12] drivers/net/can/c_can: don't use
 devm_pinctrl_get_select_default() in probe
Date: Thu, 11 Jul 2013 17:18:51 -0700 (PDT)
Message-ID: <20130711.171851.119760702736571653.davem@davemloft.net>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
	<1373471889-18107-7-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, wg@grandegger.com,
	mkl@pengutronix.de, anilkumar@ti.com, tony@atomide.com,
	jg1.han@samsung.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373471889-18107-7-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa@the-dreams.de>
Date: Wed, 10 Jul 2013 16:57:42 +0100

> Since commit ab78029 (drivers/pinctrl: grab default handles from device core),
> we can rely on device core for setting the default pins. Compile tested only.
> 
> Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13)
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Applied.
