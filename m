From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/5] net: dsa: add missing dsa_switch mdiobus remove
Date: Sat, 3 Oct 2015 13:25:38 -0700
Message-ID: <561039C2.5050105@gmail.com>
References: <560FE578.8010503@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560FE578.8010503@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/10/2015 07:26, Neil Armstrong a =C3=A9crit :
> To prevent memory leakage on unbinding, add missing mdiobus unregiste=
r
> and free calls.
>=20
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
