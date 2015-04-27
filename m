From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] mdio-mux-gpio: use new gpiod_get_array and
 gpiod_put_array functions
Date: Mon, 27 Apr 2015 13:36:06 -0400 (EDT)
Message-ID: <20150427.133606.779959918209009417.davem@davemloft.net>
References: <5503716.QxOoBLSTJz@pcimr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-gpio@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com
To: imr@rtschenk.de
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <5503716.QxOoBLSTJz@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rojhalat Ibrahim <imr@rtschenk.de>
Date: Mon, 27 Apr 2015 10:37:31 +0200

> Use the new gpiod_get_array and gpiod_put_array functions
> (added to mainline in the v4.1 merge window) for obtaining and
> disposing of GPIO descriptors.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Linus Walleij <linus.walleij@linaro.org>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>

Applied.
