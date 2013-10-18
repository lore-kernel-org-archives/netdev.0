From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 11/14] i40e: reorder block declarations in debugfs
Date: Fri, 18 Oct 2013 10:42:50 -0700
Message-ID: <1382118170.2034.21.camel@jtkirshe-mobl>
References: <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52614206.7050404@cogentembedded.com>
	 <1382106892.2034.7.camel@jtkirshe-mobl>
	 <20131018.133810.644337234048520007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-42wwmmUBGJ9BhqifEC7n"
Cc: sergei.shtylyov@cogentembedded.com, a@vger.kernel.org,
	shannon.nelson@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34310 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517Ab3JRRmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 13:42:52 -0400
In-Reply-To: <20131018.133810.644337234048520007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-42wwmmUBGJ9BhqifEC7n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-10-18 at 13:38 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 18 Oct 2013 07:34:52 -0700
>=20
> > On Fri, 2013-10-18 at 18:13 +0400, Sergei Shtylyov wrote:
> >> On 18-10-2013 17:23, Jeff Kirsher wrote:
> >>=20
> >> > From: Shannon Nelson <shannon.nelson@intel.com>
> >>=20
> >> > This is a cleanup of the arguments declared at the beginning
> >> > of each function.
> >>=20
> >>     I hope you meant "local variables" because "arguments" are the
> >> values=20
> >> passed to a function.
> >=20
> > Yes, he meant local variables.
>=20
> There is probably going to be some other feedback to address, so please
> fix this commit message when you respin this series.
>=20
> Thanks Jeff.

Ok, I will wait for additional feedback before re-sending the series.  I
do not want to waste your time and mine re-spinning the series if there
is additional feedback.

--=-42wwmmUBGJ9BhqifEC7n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSYXMaAAoJEOVv75VaS+3ONa8P/0wJ7l18rvWxzoqH+Un+pJM1
1F4sFk6QbgPRTZeIBpaZ8DQ8FdDaHtQmUWbBEkvhY8J7KDheuY4zGEMRdO73/jpC
xcX3VOk0ACfE92WVTW4ULlBvvZeYPjURrSWde6ZbV5RZU6QweZ63r1tHTjjF2fT1
93QoMaD5nc0/4/LX9yiqy2IWBHoRGx3+6bFwAEa4kaK4lemtUwDM1yUHrlE1aUXu
oM58feDBwtXDsx3CbQPMO5ulHG6UvYHGVKoWaOQZ/+46iehSoWMHjTrbAcOwUwCj
6utciBwr2hfXK1QNOuKvGlTz1LwYVFqYafXSClM3qMwq83eFo3kRH52EH2H1BXkA
PJoKYCdy+7u7TQ9HPc1DcdGHnVzyVP5qzUsso6zPiAeeKvmL2/jXwG1P0A03Q5nS
AzH/q/R7TBldNrNMqCasfjR/LPNQvkhO1LHZU6FV/7X642YhUAkBbrlxyfxt718i
F152Nyqx6n5lFZySXjloLtHkObByx6QhnBXHVFUORN0DtsBju19ijosJLxyeZ3tJ
YyDYN3/B1lXPSGBxUhMXGVxX1XaMW0K5NCvhaAo/07sv1ffCX7v6Zf7deoYuX/AJ
vb2kaB7ungpo1RXR0ZP6ApJzM2BSKJWnAORVFZu21AhXIvnjbc2mXZM3o3n5xcB4
chBa6VlNvA5mswTo1Fua
=yzQM
-----END PGP SIGNATURE-----

--=-42wwmmUBGJ9BhqifEC7n--
