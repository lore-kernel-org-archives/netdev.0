From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Thu, 23 Jun 2011 20:56:01 -0700
Message-ID: <1308887762.995.10.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <BANLkTin0QzAscKcN0Yw6rc7fUh5d5q143w@mail.gmail.com>
	 <4E033FE9.9060806@st.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-iDOrVxvqwZbvbJ4n1MoM"
Cc: Jon Mason <jon.mason@myri.com>, Joe Perches <joe@perches.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Andrew Gallatin <gallatin@myri.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46691 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563Ab1FXD4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 23:56:03 -0400
In-Reply-To: <4E033FE9.9060806@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iDOrVxvqwZbvbJ4n1MoM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-06-23 at 06:30 -0700, Giuseppe CAVALLARO wrote:
> On 6/16/2011 5:03 PM, Jon Mason wrote:
> >> stmmac may not be a good name.  Maybe stmicro.
>=20
> Hello and sorry for the delay of this reply.
>=20
> concerning the stmmac, in the past, I had thought to rename it as
> synmac
> because the driver, although was initially designed to work on ST
> platforms, today it runs on other platforms.
> The driver indeed is generic enough and is for MAC 10/100/1000 core by
> Synopsys.
> This is just an idea.
>=20
> Moreover, sorry if I'm missing some details of this thread, I can do
> rework if you agree, so let me know how proceed.
> IIUC new patches should be built against:
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
>=20
> Regards
> Peppe=20

I can make that change, I am almost finished re-working the patches with
the suggested changes so far, so I will try to get it into the next
update I post in the next couple of days.

--=-iDOrVxvqwZbvbJ4n1MoM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOBArRAAoJECTsCADr/EWU2GsH/i9zCf7upBhq1vhG3Ja+E2rZ
qkZNYX6npAOgjWu4hHFskxUgh+2e5LuqlQ+tiTAo4lHe2NqDxSg5AJoTn85mRz7n
hCNUPLePBHHoGTtrrBeCMqM2yuxNXlEKnY4rxrZ/QS3ZA5ajT+kR6qqnBwJzOYUi
6gqL4TzFU+B1Eh56c6HhNm9lDDHKn1z+e4teFTbkTTLSQNJJ9+hQ8OxLIluwo95j
PeSIXwdI9nbo0p5a9rAJEkv3qgXVpp8sXGS032W6oMcJp/652zYJfWkSrUPI1zzV
TqyqxVE/VFDJKdjSM5W5O59vLIvGe6+hqsqn6+oPB19VWUa+ZJ6L6xShd+ZKhPk=
=uxZq
-----END PGP SIGNATURE-----

--=-iDOrVxvqwZbvbJ4n1MoM--

