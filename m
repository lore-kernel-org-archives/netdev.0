From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Fri, 23 Jun 2006 20:53:49 +0200
Message-ID: <200606232053.50205.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200606171705.59498.IvDoorn@gmail.com> <20060622175546.7eebebb4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart22576529.EUHZLQ7E81";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Vojtech Pavlik <vojtech@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:28811 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750827AbWFWSti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:49:38 -0400
Received: by nf-out-0910.google.com with SMTP id o60so523277nfa
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 11:49:36 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060622175546.7eebebb4@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart22576529.EUHZLQ7E81
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 22 June 2006 17:55, Jiri Benc wrote:
> On Sat, 17 Jun 2006 17:05:55 +0200, Ivo van Doorn wrote:
> > With this approach more buttons can be registered,
> > it includes the optional field to report an update of the key status
> > to the driver that registered it, and it supports for non-polling keys.
>=20
> I think this is not specific to networking anymore, so it should go to
> lkml. Please be sure to Cc: input devices maintainer, Dmitry Torokhov.

Thanks, I am currently discussing the driver with developers
from button drivers like acerhk and acpi_acer.
If I am sending the driver to the lkml will depend on their
reaction and input for the driver. No use sending drivers to
lkml when no other driver will want to use it. ;)

Ivo

--nextPart22576529.EUHZLQ7E81
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEnDi+aqndE37Em0gRAuu6AKCxFaQADtbxEO/n0Sjw7+W0ym465gCgx4JP
CK+ogxeTjXUXnfuOsU6itb4=
=15ol
-----END PGP SIGNATURE-----

--nextPart22576529.EUHZLQ7E81--
