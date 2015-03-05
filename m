From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v5 4/4] mdio-mux-gpio: use new gpiod_get_array and
 gpiod_put_array functions
Date: Thu, 5 Mar 2015 09:58:00 +0100
Message-ID: <CACRpkdZdiV8tt6ixcwpafr3eQCB4Kesh1XcKyyYaZToLunhVpw@mail.gmail.com>
References: <1521782.cXqN30N6pA@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1521782.cXqN30N6pA@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 5:28 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> disposing of GPIO descriptors.
>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>

This looks good to me, but I need David's ACK before I can
merge it through the GPIO tree.

David: is this OK with you?

Yours,
Linus Walleij
