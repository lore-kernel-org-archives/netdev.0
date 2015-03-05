From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v5 1/4] gpiolib: define gpio suffixes globally
Date: Thu, 5 Mar 2015 09:50:05 +0100
Message-ID: <CACRpkdbGBzDx6u84t54kpr6r1dDSQDUyu5xhRrZEQD0xf4QpzA@mail.gmail.com>
References: <13969625.rHfHuA5z02@pcimr>
	<CAAVeFuKPOu530pGAnYi0M1Mfr0nn=LayWzrOA1bvbS5qU01PJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rojhalat Ibrahim <imr@rtschenk.de>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexandre Courbot <gnurou@gmail.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CAAVeFuKPOu530pGAnYi0M1Mfr0nn=LayWzrOA1bvbS5qU01PJA@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 26, 2015 at 10:46 AM, Alexandre Courbot <gnurou@gmail.com> wrote:
> On Thu, Feb 12, 2015 at 1:27 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
>> Avoid multiple identical definitions of the gpio suffix strings by putting
>> them into a global constant array.
>>
>> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
>> Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
>
> Linus, let's get this good stuff in while it still applies to your tree! :)

Yeah it's in... been moving and conferencing and stuff, sorry.

Yours,
Linus Walleij
