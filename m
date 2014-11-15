From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3] ixgbe: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 14 Nov 2014 22:21:26 -0800
Message-ID: <1416032486.2478.17.camel@jtkirshe-mobl>
References: <yq17fyxus1y.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dt3AKX66qzJRKq7l23ud"
Cc: netdev@vger.kernel.org, linux.nics@intel.com
To: "Martin K. Petersen" <mkp@mkp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46753 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbaKOGV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:21:28 -0500
In-Reply-To: <yq17fyxus1y.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dt3AKX66qzJRKq7l23ud
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-14 at 21:16 -0500, Martin K. Petersen wrote:
>=20
> Attempt to look up the MAC address in Open Firmware on systems that
> support it. On SPARC resort to using the IDPROM if no OF address is
> found.
>=20
> Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

Thanks Martin, I will add your patch to my queue.

--=-dt3AKX66qzJRKq7l23ud
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZvDmAAoJEOVv75VaS+3OUgoP/3aGuLlD0o8qEhRQ/Ex5jRZy
BV+MBCKKDFq5KNsQSwyDfp20Sbsjy0hL6ylRBj7GHU9GV9weytPi8DmVR7ZeAtIB
5YkTjxOH5sK+ztpRmPJQ9z6wVkbVBOYNl7qwPRIKdPmFzwzTrDLM/1EBJGkAGP2g
DH1Llg/0Pc0RB+57iRDgjPbZwze/KabTTjtN1B3+UO8fNj+MrdKlCq7VMpAn1Fwd
oF0d+VMJP82kZjBZguqc0aicEQ8VDmNeFHYVM0uagiqFBeMIcUGAOz/QopMV2uUa
AZFekR92UyiQD+eTCodTy6SJlsWQA9BCfomqFwI5ON4JXgbjrUTDXu4cBg9CGOPx
vE/lXisuyx+u1DFme6kGzVkd2FvWe+QLFV4dRguEQwHxwM5BvjHC4auPS5K/T1Ck
8HvA/E3MpGiGZY7eC6RCfjLrGgBXm9Rcjv5JmYM5pprXTRMGpuR0ddPsIMmNwIra
MulVdAeKiFFlNr1juX89NlTq66mbjlOAPiQsSQGgN5UsFwb8am++4W2Y/FZw6s5y
xCuWqJOyHyUgWKfO5ZVgg0Hz4nX+8vY9SUGU76Ou9bj7aXdEwb2jqm29gHAry7rb
mqyKm/ZIhxtgfUYwxdDmrRMM/NjGefrGE72C8LsEgnQI7L6oXSBUJzsow3/x6wJ1
6w9oUFG8+RqXF66oIyGg
=XBev
-----END PGP SIGNATURE-----

--=-dt3AKX66qzJRKq7l23ud--
