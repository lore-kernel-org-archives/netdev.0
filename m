From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH][v2] mdio-mux-gpio: Use GPIO descriptor interface and new
 gpiod_set_array function
Date: Fri, 28 Nov 2014 14:48:43 +0100
Message-ID: <CACRpkdZx9KJzZ7fbQBUUDonzqPT-6qbOr8U7eccLpnFAKMeGmg@mail.gmail.com>
References: <2814617.OrXEO01vgP@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <2814617.OrXEO01vgP@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 10:31 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
> gpiod_set_array function to set all output signals simultaneously.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Acked-by: David S. Miller <davem@davemloft.net>

Patch applied.

Yours,
Linus Walleij
