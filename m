From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Wed, 23 Sep 2009 09:34:43 +0200
Message-ID: <1253691283.4458.38.camel@johannes.local>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253689036.4458.22.camel@johannes.local>
	 <1ba2fa240909230023v17fe2b49v4981d464dba469ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-HZEYXHNFi7ph7PjM+kTd"
Cc: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org, yi.zhu@intel.com,
	inaky.perez-gonzalez@intel.com, cindy.h.kao@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1ba2fa240909230023v17fe2b49v4981d464dba469ed@mail.gmail.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HZEYXHNFi7ph7PjM+kTd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-09-23 at 10:23 +0300, Tomas Winkler wrote:

> From HW perspective your assumption is not exactly correct. All the
> devices are visible on the SDIO bus but they are not operational
> (probe won't succeed) until TOP download the firmware and kicks the
> devices. From SW perspective to create another bus layer is an option.
> I'm not sure if it's not more complicated one.

Ah, ok, so it is quite different. Not sure how sdio probing works, so I
guess I can't say much here.

johannes

--=-HZEYXHNFi7ph7PjM+kTd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKuc+IAAoJEODzc/N7+Qmaod4P/ReKfK/INsz2xMgjvwvRlI72
958/L76T65Qz77J7b6NVHQQcDvXt7K6S/Kx39rRO5iIM7XG2PVk58zdnFu/7PiDh
DhMWy7T/XalWi8IjorDxIAKphEzLYMFygpZoi+DznkrQMQhu2hOam97e5zDnWFdo
DUb8PWLdGy1DzfyBuPANwFtnge8ZSVW+eZUuIn/lYrGatBBLd1H+XhMsT6Ldg0ta
rfaObbA5howNYyDKuouyAFhJcHHTb8rEpWRwteLctZXp656M0k/YrBl77mk6cNMh
pwAhww1gPnV2/3CwKh6M99v+huqzV0TXgETzpXH3Ub5XE9B/+YixwBW+xGzqXhP0
MCwZBK1CuVQT5g9CGN2BmTxbdkS6WHLuswut9GHYAtcsoKqYvLF8/hJz+kQCMm0Z
NyoWprXq6n6o8f5ZxAqcXaL4yLEQgKztxeMnkB/4KlpXJSGF1K5fsTsCDwwtHQHZ
EaLeYIQDkYCM/usu9rL77+viu2RCqE7itznTtvDpdLs39Ei5CXstledyyFUw/mb+
t2WU1DdtJw830AiPYc1WVNdMMVmWs7mjteg1W0t6tmRXrKYdA9+Cs8cadWT9rzvI
QglcxAAVRIkrPqLpbmKGK/3sRT8rMyjQyHuamtg7Qost3Qqo+ZGKH10YZlAP//Zx
J93ke2NXrM8S6wcnMmyN
=+92M
-----END PGP SIGNATURE-----

--=-HZEYXHNFi7ph7PjM+kTd--

