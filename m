From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Mon, 17 Aug 2009 11:09:55 -0400
Message-ID: <4A8972C3.30202@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A87C3B9.2040206@redhat.com> <4A896648.9040707@gmail.com> <4A897057.2050504@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5D1C9FC22B74CCB11FD17802"
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A897057.2050504@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5D1C9FC22B74CCB11FD17802
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/17/2009 05:16 PM, Gregory Haskins wrote:
>>> My opinion is that this is a duplication of effort and we'd be better=

>>> off if everyone contributed to enhancing virtio, which already has
>>> widely deployed guest drivers and non-Linux guest support.
>>>
>>> It may have merit if it is proven that it is technically superior to
>>> virtio (and I don't mean some benchmark in some point in time; I mean=

>>> design wise).  So far I haven't seen any indications that it is.
>>>
>>>     =20
>>
>> The design is very different, so hopefully I can start to convince you=

>> why it might be interesting.
>>   =20
>=20
> We've been through this before I believe.  If you can point out specifi=
c
> differences that make venet outperform virtio-net I'll be glad to hear
> (and steal) them though.
>=20

You sure know how to convince someone to collaborate with you, eh?

Unforunately, i've answered that question numerous times, but it
apparently falls on deaf ears.

-Greg


--------------enig5D1C9FC22B74CCB11FD17802
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJcsMACgkQP5K2CMvXmqH2BgCdHRUTnVSa1G+FASCawIMlfhTh
YYkAoInFhI1++cCJkdg5I0ylK5AAKTcG
=nsqJ
-----END PGP SIGNATURE-----

--------------enig5D1C9FC22B74CCB11FD17802--
