From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Thu, 13 Mar 2014 00:28:48 +0000
Message-ID: <1394670528.20857.10.camel@deadeye.wl.decadent.org.uk>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	 <1394578747.28839.4.camel@joe-AO722>
	 <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
	 <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
	 <1394663197.3915.61.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1BTaVrWKtjntL7CKQjqd"
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34843 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751490AbaCMA3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 20:29:03 -0400
In-Reply-To: <1394663197.3915.61.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1BTaVrWKtjntL7CKQjqd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 15:26 -0700, Joe Perches wrote:
> On Wed, 2014-03-12 at 21:14 +0000, Ben Hutchings wrote:
> > These look like the statistic names specified in IEEE 802.3.  I would
> > support a general move to using standard names for MAC stats in Etherne=
t
> > drivers, because they are quite clearly defined and widely implemented
> > in hardware.  However, that is not the current practice in most Linux
> > drivers.
>=20
> Hey Ben.
>=20
> Maybe something like this would be a start?
>=20
> Change the actual #defines/strings to taste.
>=20
> Maybe this shouldn't be in uapi or maybe in if_ether.h
[...]

This is pointless without also nailing down the definition of each
statistic.  That could be done with reference to standards/RFCs, of
course.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-1BTaVrWKtjntL7CKQjqd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyD7wOe/yOyVhhEJAQoJZBAAjYhkPhYHFb8jMyUbAtW9tZtCe337LRJk
KI60VOoleg2o4/ElkkhnPywwmfr4hkmza7zwDZMiknzO1MdlDH9ayTq/IGTpUZqu
Z5OXQe+Arw8m/vIh+9u3hK/ksJ/IQmxmr4KyacEOBPNt9QpGa+9WFstgcw8Jnq4E
kgfMqgnWRUOcTZM6s07a0JnE82iL5VnxEhoMpp3x4vgg/ew0u1y733oPSSuuC0xR
YZ0A7bWAnPUlqKchCu+Iyp+K7y7Wj3lx/pmw+/VjERBEAPT4FiwbLOk46PMsYKP2
gHI3ArrcS/xbhUmDEmJYFMX29e8OqDw1nZUAHgki+gXvLICTIJBol/3Z9hW8HkoG
QGGsfDP3WBT+SsUapNUKTYiDU6yyObbaMFaQ0v91mwQm5v8t812avjJnaqhqTIXX
sPvmAjBciM57DiJ97g8WF7xAUrY90SeLutTNC5QSyPKfUzW0ooTc3Wb/AUddzuKi
dmf1XPp8T8gfOtszas5S0TtL/A1eZxy1Th0PZsK8etYsOJPh4Rv772ZmILCGpWBy
XU589Cirny8TfMrJDZpY4oGnuCdf5Y3L2wLAdNSX5JGOENTSik+aY1/YwRV0smf7
+QVVKiIW1/NhINAvCPqJxaMlP4OoyzCGozfUDsxEC5nzGi7xCmh7nXgy/tzYW+4J
4tTTvk2NcIk=
=7rZl
-----END PGP SIGNATURE-----

--=-1BTaVrWKtjntL7CKQjqd--
