From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH v5 1/4] gpiolib: define gpio suffixes globally
Date: Thu, 26 Feb 2015 18:46:26 +0900
Message-ID: <CAAVeFuKPOu530pGAnYi0M1Mfr0nn=LayWzrOA1bvbS5qU01PJA@mail.gmail.com>
References: <13969625.rHfHuA5z02@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>,
	Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <13969625.rHfHuA5z02@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12, 2015 at 1:27 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Avoid multiple identical definitions of the gpio suffix strings by putting
> them into a global constant array.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>

Linus, let's get this good stuff in while it still applies to your tree! :)
