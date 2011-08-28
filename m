From: Ben Hutchings <ben@decadent.org.uk>
Subject: TX watchdog warning for sis900
Date: Sun, 28 Aug 2011 21:38:24 +0100
Message-ID: <1314563913.9176.55.camel@deadeye>
References: <20110728174246.15403.5914.reportbug@acahkos.lan>
	 <1312133149.2591.7.camel@deadeye>
	 <CAPC6j9mg7vuOtVWQf-SyuQjaDQ3zD2Oz5AUFmP26S8CsHUw_0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+4coclIQHh1TnNn6Trmq"
Cc: 635770@bugs.debian.org, Daniele Venzano <venza@brownhat.org>,
	netdev <netdev@vger.kernel.org>
To: Simon L'nu <simon.lnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44046 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752134Ab1H1Uil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 16:38:41 -0400
In-Reply-To: <CAPC6j9mg7vuOtVWQf-SyuQjaDQ3zD2Oz5AUFmP26S8CsHUw_0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+4coclIQHh1TnNn6Trmq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Bug log is at <http://bugs.debian.org/635770>.]

On Tue, 2011-08-02 at 16:25 -0400, Simon L'nu wrote:
> On Sun, Jul 31, 2011 at 1:25 PM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> > On Thu, 2011-07-28 at 13:42 -0400, Simon L'nu wrote:
> >> Package: linux-2.6
> >> Version: 3.0.0-1
> >> Severity: important
> >> Tags: experimental
> >>
> >> hi,
> >>
> >> so at random times, the driver will just oops with (below), and then t=
he
> >> network just conks out, unable to do anything. when i remove it (modpr=
obe -r) after bringing
> >> it down, and back up, it's extremely slow (see below kernel oops messa=
ge).
> > [...]
> >
> > Did this happen with any previous version of the kernel package?  What
> > is the last version where this did not happen?
> >
> > Ben.
> >
> >
>=20
> no, and only started happening recently. i also tried 2.6.39.2, and it
> started happening there. made me suspect an hardware or firmware
> issue. the PXE firmware option was enabled in BIOS (it's the built-in
> NIC).

Do you mean that you recently enabled PXE boot and that this has started
happening since then?

Ben.


--=-+4coclIQHh1TnNn6Trmq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlqnQee/yOyVhhEJAQqZuRAAzMsIZ1l7qgWYYovcyvDUUTNdC8TXlTld
Mm7WT9AuK4l2MHS6u5N+7uJFdfUyIeYNCRc4whn0P74cZB8zBJIchoolsXRhmT1S
ozDr9m116CtyJ8EL5JqUdCNaEy9VTJhc0FUHuU9gjDEuaOuBVQd/13vZdVjqXM6c
GNOobOJuyP3UDBO/znUIQT+D26GmzIoaK5BtVXgsAdMme8iqO3MBijuRggw/DGIe
o2Aq3ncxDbPoOGb7piDH3P5567OisgP20CBHmTLCxjj+j1OFFv6pARNlgtT4kBie
UraNd7AmPHu2AGQ9Hml4LwNrSVeQiAQwLE/lhy7aqa65UD2Pdy8ziuC0Ajb0DKp/
nn1Ae3dvrE3zkv9i1G1eejeCLCT+hfzf7Yxz2gAY8vwXT1pb8kqqpKN6JG1Vw3Hj
mu2Qvhnyzhy0y0X82Yx5GTL20+J0MlHCgrGd0upIpgqGoLmvrcpu45d549o3q2p1
5Yjk7/m8XO0bOAtfIQp1FZwgVaxC2KXR1qI/INhUCJyfl8CAOxuV4eE02lVDQznW
H3cy0wHfDWtWnB2jby/vORVq+sYlAnytUabTgTRjF36NCVcw+SrT0iY5lhFnRggw
JjIQz8BqF2F3Aq4J4fmcOvD05KoZ/49IY/E40YBtEEdjZHMACvibgGO0V5xuVR1B
jFV6aqmwZ6M=
=dNjd
-----END PGP SIGNATURE-----

--=-+4coclIQHh1TnNn6Trmq--
