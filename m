From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/14] i40e: separate TSYNVALID and TSYNINDX fields
 in Rx descriptor
Date: Sat, 07 Dec 2013 13:40:51 -0800
Message-ID: <1386452451.2195.37.camel@jtkirshe-mobl>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1386382643-29055-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZKXASf832Q7r+Sz_QU=nAFZVtQEa18etH97Xb-ECOnLag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1JXrQe2kfJ0kOS59UimG"
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33004 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab3LGVkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 16:40:52 -0500
In-Reply-To: <CAJZOPZKXASf832Q7r+Sz_QU=nAFZVtQEa18etH97Xb-ECOnLag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1JXrQe2kfJ0kOS59UimG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-07 at 23:33 +0200, Or Gerlitz wrote:
> On Sat, Dec 7, 2013 at 4:17 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Jacob Keller <jacob.e.keller@intel.com>
> >
> > In order to get 1588 to work correctly the defines need a bit
> > of a tweak.
> >
> > Change-Id: Ie50ce2a18e1593441f1560411e5a4f51c6d48aaa
>=20
> Hi Jeff, we also use this token with out internal gerrit system but
> make sure to strip that before sending upstream, are we OK for
> upstream commit to carry such tokens from the vendors systems?
>=20

I asked that question to Dave last week and to summarize the email
thread, "if there were commit's in Linus's tree with the Change-Id
information, then we could do something similar".  We originally were
using "Internal ID:" but since there was some documented use of
"Change-Id:", we adopted the use.

>=20
>=20
> > Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>



--=-1JXrQe2kfJ0kOS59UimG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSo5XjAAoJEOVv75VaS+3O3XsP/2RRIhAw+6R6dfS1EN8nxQnR
389CIx1HHSasspiFNuTr8QqR7qQR/Rx43KBtNQVr9dSZI85W6VjIcuJ2mP3qDO68
Fo0UQN3NmiM64/kPUTb8kwTqwelwu2CMO1mX4iRQIED7c0nq7EAiufNtlEKgtScu
UiPXT1Q4z2y86eiWvAi3H/eUYnLgqDE8ktX5hr41ftqP2BFBoYsXWonlh1Hpp8IY
TL4xT9aSZywtFcFXG3m4e83hSw2Wblk6n9uDNzT9Emwm4kZUZPGJRXvPwEK6sH/A
F3Ra+luNn4Npk/smYqHkzA8y/HAvOidqXvqn6698nf8VXHfiqXWk6C1FFPYRv4/s
sZ3Y0mCuWizaCZuxfBNeN+qTntIntGXZvJz0467DAJ3Fm1jVQI1x596sGFsQOsLa
CtVBgGjO3QCmoAhGkoBSsA20JK+urYs+tIUaKo7EO+ect16A3Fm68KIOloaZ9UGC
NcVW124UXUlO42oR9h7gh0EOiQzd5Y0swoAHqbMGVnIEI7IUB/RPqg+jB6T9KEbu
UkYvCv68yNF2jqWaRMWe40AqgX8jlew4IN3OwOir+r2VNlQWVqAGqnOS/p98GTf2
NV1aG5WK74cqwhaQ/TOtJfdfQ1l9m39HJXaHiqbATewC1zxI9dzwTxABBxA5bTww
XmhyIYCqqfpZgTqv2Nfw
=2Xj/
-----END PGP SIGNATURE-----

--=-1JXrQe2kfJ0kOS59UimG--
