From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Per route MTU settings are broken in linux kernel 3.2
Date: Wed, 26 Jun 2013 02:12:26 +0100
Message-ID: <1372209146.4006.35.camel@deadeye.wl.decadent.org.uk>
References: <1372063443.32157.10.camel@linux>
	 <1372077951.21189.16.camel@deadeye.wl.decadent.org.uk>
	 <1372079315.32157.15.camel@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3pqCePKAFTA6m7+Icio4"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Yura Pakhuchiy <pakhuchiy@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1372079315.32157.15.camel@linux>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3pqCePKAFTA6m7+Icio4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-06-24 at 20:08 +0700, Yura Pakhuchiy wrote:
> On Mon, 2013-06-24 at 13:45 +0100, Ben Hutchings wrote:
> > On Mon, 2013-06-24 at 15:44 +0700, Yura Pakhuchiy wrote:
> > > Hello Ben,
> > >=20
> > > Looks like setting per route MTU (as described in [1]) is broken in
> > > Linux kernel 3.2. I tested with newer Ubuntu kernels 3.5 and 3.8 and =
it
> > > looks like problem is fixed there. I filled Ubuntu bug report [2] wit=
h
> > > more details and sample script which illustrates problem. But since t=
his
> > > problem is probably also present in stock kernel (not just in Ubuntu)=
,
> > > is it possible to backport fixes to stable 3.2 series?
> > >=20
> > > 1. http://lartc.org/howto/lartc.cookbook.mtu-discovery.html
> > > 2. https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1177507
> >=20
> > Sure, what are the fixes?
>=20
> Actually, I do not know :-( Ubuntu devs have not fixed this problem in
> Ubuntu 3.2 kernel. But these commits in mainline kernel looks related:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D9b04f350057863d1fad1ba071e09362a1da3503e
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D5f2d04f1f9b52604fca6ee08a77972c0df67e082
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3Dd851c12b60471188e15e5c8405b289073e8dd025
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D7f92d334ba19a0d8e96f8f8f092219553367d921
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3Dee9a8f7ab2edf801b8b514c310455c94acc232f6
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D38d523e2948162776903349c89d65f7b9370dadb
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3Dfa1e492aa3cbafba9f8fc6d05e5b08a3091daf4a
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D05ab86c55683410593720003442dde629782aaac
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3D9cb3a50c5f63ed745702972f66eaee8767659acd
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/comm=
it/?id=3Db44108dbdbaa07c609bb5755e8dd6c2035236251
>=20
> However I'm not sure whether they all are required or sufficient to fix
> everything correctly.

Sorry, but I really do need someone to tell me exactly what's required.
I'm not likely to find the time to work this out myself.

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-3pqCePKAFTA6m7+Icio4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUco/+ue/yOyVhhEJAQpBsxAA0Wxus9cvoZxfoOSi10wa2d+MvbqYihkh
cEZl0XllDIrx7f//FCzxBaVWzosJjaE05DSPFUaOTmAcgQaaftK3QzQKA1QIqqTa
WhFvQbwsxt9RWRZbev43V/WaV/cMjdF5Y+j2Qm1fI639EF2QuAksgE+jn0aEbsAh
1OXz0GHVFg0i0pYh+UyqRxJg+FUtLKfc85Cak6b6F/q/PXRI1cwyYxYYIdUfuf/x
WPE6m4efMS7I6w3A7+GaFZzrvj/5lVeAKuxvLlpuPBGHJHgwd0H3KateyZtiib7o
yBvIL/UiJTehV17a/W1FUhBsas5q3whTWHBRLl2D1TpvX7X8THly6nnByF4La+xL
rS3bqY/R0jq8QcAaPIlMm4yi1UIg+t8NDcjjWQQdBASev10Uu5Bwb9hpxa6D2yJn
kzqlECX7dz+FtyJwaCIkxsfoA41za56KMh4cJtVXmgTHxD/6gZGDRy5MkUZQ/flr
7xJAnC+DpRPyBWtQa266N/ILW4MTGa0Wz4vQpEBufg1tV1+57N0WATMDcXBnOIOa
QGuR8X9TvIB0VfN52IFI4zH6sExxuzAtXm9d4Jlr50rbuDM+mcSCngfWJj72hw40
E8ztTB0xLs0cpkcff108+cYxP4EYqz0LA2ZLlqUNZyaNjkz8ekDDUdh1rMwDCDtn
sboaNXDwbns=
=W0jS
-----END PGP SIGNATURE-----

--=-3pqCePKAFTA6m7+Icio4--
