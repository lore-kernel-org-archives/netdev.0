From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/6] 6lowpan: move 6lowpan.c to 6lowpan_rtnl.c
Date: Sat, 22 Feb 2014 14:07:15 +0000
Message-ID: <1393078035.15717.103.camel@deadeye.wl.decadent.org.uk>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
	 <1392995711-19563-4-git-send-email-alex.aring@gmail.com>
	 <1393076452.15717.98.camel@deadeye.wl.decadent.org.uk>
	 <20140222140344.GA1032@omega>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-w/QxyKd5V8AGqoOA8XBO"
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, martin.townsend@xsilon.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57060 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbaBVOHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 09:07:24 -0500
In-Reply-To: <20140222140344.GA1032@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-w/QxyKd5V8AGqoOA8XBO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-02-22 at 15:03 +0100, Alexander Aring wrote:
> Hi Ben,
>=20
> thanks for your reply.
>=20
> On Sat, Feb 22, 2014 at 01:40:52PM +0000, Ben Hutchings wrote:
> > On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> > > We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
> > > should move 6lowpan.c to 6lowpan.ko. Then we can support multiple sou=
rce
> >=20
> > You put the wrong filename here ^
> >=20
> mhh, I meant here:
[...]

I know what you mean, but the second '6lowpan.ko' in the description
should surely be '6lowpan_rtnl.c' like in the subject.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-w/QxyKd5V8AGqoOA8XBO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwivE+e/yOyVhhEJAQpHJA/+Lod2hafoUaNzzjTJsvqcE9LcRmtsy++m
lUYuxHQByMUJc3GemoQMQfH18JoX9OPQHjvexzg5QIBcsdxiRAvxvW/Vmy5hxFKC
pOtPI/lnDTzplBxXFfQDrtsSBVa1u9+zp8zMBndpSAYhV1VYCtR0VUMZe8+fHsev
+/LN7pVZsQYwScllT+S5kHzIftxISjALEQQZLl2BsEw6GwBwZBz4I+tG2he3m6e0
OqxNuJAudmxV5fPOAd3djRzfEmarss5ZSMpRnODropyvG7/XbTf+uloNAxYP3Nj0
XGhkPOB3wwnBLPDr56W2kDF0qbsP6SBpXa1LCLa2qikiTTsmsrJLUbIj8dWK6h7K
VvvDq1wBWNHaESp0REifbfNqfOZGcbeQE14HiSoVqs1F9/0/RavQ9nuz0jmCHkkR
yeyjHRUFRFcQS9j03ENVpJFTk1WDTEWRdWwRNbDt5QGDsaM6R+ABEdjCQ6gQLRdQ
20CvczCh7uBnwzo/TlVzB3jaIH/dFf0PfnhLj3AVz3CGgl9UTG/AQW5YWvogWvYV
OWsUcLQ0jgUinfMTNdgaOc5Aa0dOiloAiw9SPeDwpBcxIGTqj1t71cXKbtxfxewM
AzVS7TziMKWteUc6K9mVJcJXryyUXEbLyNMcn4w2yDO6EDv3wakSan3OH3S5ZIpe
j79rQNhKxng=
=tYgJ
-----END PGP SIGNATURE-----

--=-w/QxyKd5V8AGqoOA8XBO--
