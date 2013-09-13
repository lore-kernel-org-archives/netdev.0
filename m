From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 4/7] ptp: switch to use gpiolib
Date: Fri, 13 Sep 2013 14:22:16 +0200
Message-ID: <m38uz0vrlz.fsf@intrepid.localdomain>
References: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
	<20130910141912.GB5088@netboy>
	<CACRpkdZOCkLmgQHZSiqQfvLp=WzNsaE5AcY3siJ0b=bL0Xv8Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Cochran <richardcochran@gmail.com>,
	"linux-gpio\@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Imre Kaloz <kaloz@openwrt.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CACRpkdZOCkLmgQHZSiqQfvLp=WzNsaE5AcY3siJ0b=bL0Xv8Pg@mail.gmail.com>
	(Linus Walleij's message of "Fri, 13 Sep 2013 10:38:21 +0200")
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Walleij <linus.walleij@linaro.org> writes:

> Thanks, I have found numerous active hobbyists using the
> IXP4-based NSLU2 NAS machine for various things - mostly
> non-network related as it happens, so it'll be with us for a
> while I think.

IXP42x are most probably "end of life" in the commercial sense, but the
newer IXP46x/455 and even newer IXP43x are still being sold. For
example, Gateworks have a couple of IXP43x boards ("Cambria") which
I personally find interesting, for some specific applications.

There is no platform driver for Cambria in the official Linux, guess it
should be changed.
-- 
Krzysztof Halasa
