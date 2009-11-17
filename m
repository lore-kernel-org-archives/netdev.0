From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 15:04:52 +0100
Message-ID: <1258466692.3682.12.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <20091117135817.GC27743@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-JRV/EpuRkHQhC324dy6n"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Felix Fietkau <nbd@openwrt.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57437 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbZKQOFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 09:05:17 -0500
In-Reply-To: <20091117135817.GC27743@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JRV/EpuRkHQhC324dy6n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-17 at 08:58 -0500, John W. Linville wrote:

> > To avoid such mistakes in the future, disallow adding a
> > wireless interface to a bridge.
> >=20
> > Felix has recently added a four-address mode to the AP
> > and client side that can be used (after negotiating that
> > it is possible, which must happen out-of-band by setting
> > up both sides) for bridging, so allow that case.
> >=20
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
>=20
> ACK -- we get these complaints fairly often...
>=20
> I don't think I've sent the 4addr stuff to Dave yet.  Should I just
> take this through my tree?

After ack from Stephen maybe?

johannes

--=-JRV/EpuRkHQhC324dy6n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAq2BAAoJEODzc/N7+Qmaad4QAMJAXHaAV72jJRbUuIrIck2v
p4CzJS4O0gOfTiKQ2P2dJxt84PZxRS0cDsmXdNT95ShAcTrnDo/g7wM0m32cp2kv
uaLTrWkDb9agKstTFsWxmXlqZhXgm4wHjpsnmL0Hy8Qmr0Ia5zKvIuG/Oe9PvHBc
TFfWQX78p3Q7DCpPDFXWbIcwG2S4CcMLroR+d1iO+SY0eGchAndkco39i60ZoB5D
C9iQq9T+DmZB166BzT09pohCW7vR6BX8a3yeg6a4rwCJLLM/taRLic1XlryTk3z7
K9WUU7PTFPDMHDdmjcUx+wTYPvywsmyYkfSmWFWYPz0U7uJY7vf0ExMqHIKfsRqr
nSJpakHbaiTxTM3iB7IcPvnHgXarfUqILhv95QFQ7O0ehQZ0UHSyZXGXZRy+4BfR
uR16aqT6xE0keSs7k6GUdprpUsgKRJqz7IQfKAuVL3xEN/TSqASO4EAVI4E0PZ3Z
UpjMy6/G3RF2VkD/0ci7T0x3U6XiD0Csgu+EjgUhzuf98NYIwbFmKae1FcArN/XY
XBEjw+3KSDTQbloJWGzBn093amx507VE+DW0riuuT2GUM0q5shYbg54O9wPGqACl
Z3KQTZnwbcYQ6rK2aBP1puLp6ESL314MoOHWTIZO32MKzxd8PQSxTj4P3qlWH/Qh
Cv1hU0oq5wm0LqVt4Jg7
=m1uT
-----END PGP SIGNATURE-----

--=-JRV/EpuRkHQhC324dy6n--

