From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 20:31:20 +0100
Message-ID: <56EC5788.3030509@free.fr>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160318191242.GQ4292@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/03/2016 20:12, Uwe Kleine-K=F6nig wrote:

> On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
>=20
>> What would you think of making at803x_link_change_notify() print a
>> message every time it should do a reset but does not has a way to do=
 it?
>=20
> Then this question is obsolete because the device doesn't probe.

I don't understand this statement.

What does it mean for a question to be obsolete?

Regards.
