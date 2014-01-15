From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH v5 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Wed, 15 Jan 2014 15:58:24 +0100
Message-ID: <1389797904.2972.16.camel@dhcp-25-241.brq.redhat.com>
References: <20140110.181030.2081631538801450145.davem@davemloft.net>
	 <1389796619-13440-1-git-send-email-thaller@redhat.com>
	 <20140115144331.GF19945@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-n7lFP354hkgzfwlR9MOu"
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaAOO6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 09:58:38 -0500
In-Reply-To: <20140115144331.GF19945@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-n7lFP354hkgzfwlR9MOu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-15 at 15:43 +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 15, 2014 at 03:36:57PM +0100, Thomas Haller wrote:
> > v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
> > v2 -> v3: reword commit messages, code comments and some refactoring.
> > v3 -> v4: refactor, rename variables, add enum
> > v4 -> v5: rebase, so that patch applies cleanly to current net-next/mas=
ter
>=20
> Huh? I thought those were already applied?
>=20
> Hmm, they seem to be in no repository? I hope that no other patches are
> affected, too.
>=20
> Greetings,
>=20
>   Hannes
>=20

I thought so too, but I cannot find it, so I re-posted v5.

Thomas

--=-n7lFP354hkgzfwlR9MOu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJS1qIQAAoJECnCNm5N/FcoLYcP/3BIpKGC2RMnf6yTtRPeCC1s
Dk8o8paPi71RJBFrEjiy1NMVFV+sVGypisndRHIFjsnEu3SRPu5OlbT/76xKWx/I
g8VyzuxwUFhVuepFlMwTsrazRAaJ2/9qezVl83xSLVI0prvv9OO82jgcfthdLsVv
Hm8BPYd04KepbdOhsM/95JHGX92KMUrEMlodf93ZptzMgBD+VfEehnpwGdusaEjC
bVO3dq2kmOKjfRU4yjuCR4F8Gjc4wu+4NZVrUTbojtPFZm0w8R7doQAjXcXvX2iD
jJ3XzhwDOKqbgC0VrYbyjQh+4b/fdzbAlyNIsHiiOC/3nju0yMMZBTI+1xKO7GLT
KI990/mZFo+lzBD3lx5rjd/kITimhcAOGuaI157/VytZUEqgnM4/Uy8sq3GB7Y1n
JoEjaJ3iopFU7sQtUUPP4mivnM3X60G0WRMOj8d2WGVx+DwHop7n6XQy3YQTnjjM
YGBbD4w2m5POYv6AQPFyPGta1AclcfaeTr/cow6MpEf+fldRBZYb+fXrRNk6xpOx
ku5AWh5FzhzW3Dr2o4CzlQUJTnEWNo9VGZv0FMYLEa7Xe0IJSl6dVi5025qOMku8
EA5x7B8w+gaIl7y1og7pb7EqDqqZnqIbxu9rp3qcR2EJXSP7tcjKIry1gCroeSbd
ZhkThER+RBiZS4dDqSkI
=c5Ct
-----END PGP SIGNATURE-----

--=-n7lFP354hkgzfwlR9MOu--
