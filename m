From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 27 Nov 2008 12:50:04 +0100
Message-ID: <1227786604.3809.90.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <1227783281.3809.78.camel@johannes.berg>
	 <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
	 <87k5ap2xw6.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-NmrWKny0b8ezF8navmjd"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44184 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYK0Lus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:50:48 -0500
In-Reply-To: <87k5ap2xw6.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NmrWKny0b8ezF8navmjd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-27 at 12:47 +0100, Andi Kleen wrote:
> Marcel Holtmann <marcel@holtmann.org> writes:
> >
> > Either we do Ethernet framing or a pure IP device. I am for the pure
> > IP device with a separate ARP header (which we managed to get
> > allocated). Wrapping everything into Ethernet only because dhclient is
> > broken is not an answer. An alternate option would be a point-to-point
>=20
> It's not only dhclient, but also lots of other raw packet users like
> tcpdump etc.

tcpdump works fine on almost anything you throw at it, I have a hard
time believing it wouldn't be able to decompose rawip easily.

johannes

--=-NmrWKny0b8ezF8navmjd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLoloAAoJEKVg1VMiehFY72cP/j+PMdJKL4bmQvG13LEHG9AX
OU3HVlFWIr4ry8pNv+ufWj1puZ12pFuv+Pn1AFH/IOoqxdI53+nFPHE3fCO2RVqX
AdagyoGK3oGEmGmMPvtZnZv3l5Ggg3gNJj6pMDYLqgYWvPwMaa2nxwLbT74BH3N4
+SVQeb6RHADWGCrw93BJh34yHIlblIihdvt3HFzLQBYwQ+MLPAJEoyXJuTTchPHd
BkhCQlBrbhxDkKnYtnEwF8VQ4xC3uuM5Tio1IhMtTAUx1erCCjJtx6bP3f+mtc7O
RS6WEMDLFsVRIm5QV732K0RVlGyhXpjPcoJ56+WL6asMVBHtdCEKzAq0jHQhB/8y
cKcZpik+s8jSWLCbhzQJOULPhyXfbTHo5GUQiYTivx61qp2ZdtgMz4HNFwKc/9qQ
UbY2XtX6Vkwybuc1TajezTRXMQHtH+DHOaP87q4lTbaCFDGHkEEJ0gRZ4RwQ8czo
5WPZQmEwOtcfecPNiu0qcTeJQzwFp6FbI/idTCV97mvsEWdZ+3TxO3oezrsJu426
MTOkAXJBHhWOgSgvJi2SSji1eW+4jiBnroC/iRL8Jnehi3WYv29+JaFoN0ViPoO3
tb1bSbRFRZQ0ZC9kYVxU3TEXzvchEiRSJmO4qNQW0qpkMTM/GS6CBBeUm90ZGgQt
fT9wX4srKrXw9951KZvC
=wQJe
-----END PGP SIGNATURE-----

--=-NmrWKny0b8ezF8navmjd--

