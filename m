From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/12] drivers/net/can/c_can: don't use
 devm_pinctrl_get_select_default() in probe
Date: Wed, 10 Jul 2013 14:14:56 -0700 (PDT)
Message-ID: <20130710.141456.975401714119737529.davem@davemloft.net>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
	<1373471889-18107-7-git-send-email-wsa@the-dreams.de>
	<51DDCC01.1090104@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wsa@the-dreams.de, linux-kernel@vger.kernel.org, wg@grandegger.com,
	anilkumar@ti.com, tony@atomide.com, jg1.han@samsung.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <51DDCC01.1090104@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 10 Jul 2013 23:02:57 +0200

> On 07/10/2013 05:57 PM, Wolfram Sang wrote:
>> Since commit ab78029 (drivers/pinctrl: grab default handles from device core),
>> we can rely on device core for setting the default pins. Compile tested only.
>> 
>> Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13)
>> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Who takes care of this patch/patch series?

Good question :-)
