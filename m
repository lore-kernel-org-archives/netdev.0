From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v5 1/4] gpiolib: define gpio suffixes globally
Date: Thu, 5 Mar 2015 09:49:31 +0100
Message-ID: <CACRpkdanVgq3V7gmOtQWLbzPnL4WQBTfULtze3yWtSSOALCAHw@mail.gmail.com>
References: <13969625.rHfHuA5z02@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Alexandre Courbot <gnurou@gmail.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <13969625.rHfHuA5z02@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 5:27 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Avoid multiple identical definitions of the gpio suffix strings by putting
> them into a global constant array.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
> ---
> Change log:
>   v5: move the global definition to drivers/gpio/gpiolib.h
>   v4: no change
>   v3: add this change as a separate patch

Patch applied. This v5 version. Sorry about the other fuzzy message.

Yours,
Linus Walleij
