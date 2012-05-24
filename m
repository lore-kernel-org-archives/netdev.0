From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
 - add snooping functions for ARP messages
Date: Thu, 24 May 2012 10:09:55 +0200
Message-ID: <20120524080955.GA14941@pandem0nium>
References: <20120523214802.GA12222@pandem0nium>
	<20120523.190158.2172815395820691292.davem@davemloft.net>
	<3476925.EJY4MZoOgZ@sven-desktop.home.narfation.org>
	<20120524.015457.1543147002306809286.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120524.015457.1543147002306809286.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey David,

thanks for your answer,

On Thu, May 24, 2012 at 01:54:57AM -0400, David Miller wrote:
> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Date: Thu, 24 May 2012 07:34:12 +0200
>=20
> > _You_ were the person that declined the pull request because _you_ want=
ed to=20
> > rewrite the ARP handling. So _you_ are the person that has the insight =
in=20
> > _your_ plans. Either _you_ tell us what is _your_ problem with it or _y=
ou_=20
> > will have to point us to a person that knows _you_.
>=20
> If I say that you must not use ARP nor neighbour layer internals, it
> doesn't mean that I have to come up with the alternative
> implementation for you.

well, thats pretty much answers it. If we must not use ARP or neighbour
internals, even after your rewrite (?), we have to come up with an alternat=
ive
in any case (write our own backened).

We don't expect you to come up with an alternative implementation, but
as you are the one accepting the patches (or not) we need to know why
you decline something and what the problem is so we ca n work around
or improve.

Thanks
	Simon

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk+97NMACgkQrzg/fFk7axa4NgCgzysVur931TOmd4kHsjUaSG2J
elIAn2yOn2AGcBPI8+iP6AOxLCnxe4VE
=27P2
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
