From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Tue, 01 May 2012 15:52:06 -0700
Message-ID: <1335912726.2656.16.camel@jtkirshe-mobl>
References: <20120501.174914.654247970871851432.davem@davemloft.net>
	 <4FA05ED2.3030608@candelatech.com> <1335912148.2656.11.camel@jtkirshe-mobl>
	 <20120501.184650.450772649940152534.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Osz6XGyxlSbRtyjxuiN7"
Cc: greearb@candelatech.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11964 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481Ab2EAWwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 18:52:07 -0400
In-Reply-To: <20120501.184650.450772649940152534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Osz6XGyxlSbRtyjxuiN7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-05-01 at 18:46 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 01 May 2012 15:42:28 -0700
>=20
> > I will take care of the stable submission's Ben.
>=20
> Actually, Jeff, hold off on that.
>=20
> I misread Ben's email and didn't see that these were not
> driver-specific changes.
>=20
> Therefore, I'll take care of the -stable submissions and you don't
> need to worry about it.
>=20
> Thanks everyone.

Ok, sounds good Dave.

--=-Osz6XGyxlSbRtyjxuiN7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPoGkWAAoJEOVv75VaS+3OdggP/0/mZHvEVSI0ZfHg9xlTwT8j
9rkKUg6cNiwGmZlFA+Q/RdzSc74DLYWHQXIS75cpbmy6qdfWM8RKFPsngQqDVDvP
jJ6gvto174Y25bD0KmNRNlyPLyaXBn3BlK3xXCaqPaT5VLkPuKs0rJDOr2v2RMg9
2Yh68lqks+pOYLCwCBmRw9l5rhLHFI/9TB4uaVOUVzELwGmtqwjsedlR0OJLjTAk
erZcYAX4mjIiPBarZNpehDbcCkfxuRak+W/B+rkzX/0eJuXV4OSP6TrTis57sqEL
WA9NKfMcWkISlpbApnJCEHNafB66BtGItfYjvAXwKZRK2jimizNMMQyu3X+FEkC8
TcfQHb98aLf0vrSMU+wbdfcv3bdpAYmA1q/lQc8omQh3e9s/wDE4yX3wv+ZTF+k0
tmDoCjXEp07qpDpIwziTb5wkH4p6ynnmq6WZJdWr7sriIRF6PksiW1cqwVkZSEdo
n8/35QEJOexmM7pY/6RYTpiXB+q0Yfpqhu34kuvu0VSwMTOjueD5h47vDYyY5C3u
ExkjaoST1YUxYEjmU+hD6WtN/Qb4o1P2V5ZV0R3nGTZnxu/eEtS7vpjuC8yFfLQ/
Zck6jyszdBcP0Yx/6yBzh2k588qj6EQxuGNMoVqGnz4Nov5L2xsNgie11jMSmRLZ
5jjvwYRxYQANGpReS2pY
=t/X9
-----END PGP SIGNATURE-----

--=-Osz6XGyxlSbRtyjxuiN7--
