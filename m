From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v5 3/4] gpiolib: add devm_gpiod_get_array and
 devm_gpiod_put_array functions
Date: Thu, 5 Mar 2015 09:56:26 +0100
Message-ID: <CACRpkda7VkZ_QXHoK6eH9HM1Ec3Vt4KsUFSFWcnEbaq3LZZuNg@mail.gmail.com>
References: <71195660.CBS4fRPfXg@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <71195660.CBS4fRPfXg@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 5:28 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Add device managed variants of gpiod_get_array() / gpiod_put_array()
> functions for conveniently obtaining and disposing of an entire array
> of GPIOs with one function call.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
> ---
> Change log:
>   v5: no change
>   v4: no change
>   v3: make the flags argument mandatory for the new functions
>   v2: add this patch to the set

Patch applied.

Yours,
Linus Walleij
