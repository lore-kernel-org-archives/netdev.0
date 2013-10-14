From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [RFC net] bridge: clean the nf_bridge status when forwarding the
 skb
Date: Tue, 15 Oct 2013 00:35:40 +0200
Message-ID: <20131014223540.GC3873@neomailbox.net>
References: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
 <20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
 <20130926211648.GB1228@open-mesh.com>
 <20130926143248.2799b4ea@nehalam.linuxnetplumber.net>
 <20130926220143.GC1228@open-mesh.com>
 <20131014222010.GB3873@neomailbox.net>
 <20131014152756.7b83dcc0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZmUaFz6apKcXQszQ"
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27850 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218Ab3JNWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:36:11 -0400
Content-Disposition: inline
In-Reply-To: <20131014152756.7b83dcc0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 14, 2013 at 03:27:56PM -0700, Stephen Hemminger wrote:
> The patch content is fine, but it needs necessary ifdef's.
> I would also prefer to have the clean done as a function that can be stub=
bed out
> like the other bridge netfilter stuff.=20
>=20


Ok, I will apply those changes and I will send it as PATCH.

Thank you very much for your feedback!


Regards,


--=20
Antonio Quartulli

--ZmUaFz6apKcXQszQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSXHG8AAoJEADl0hg6qKeOP8UQAKpfoGnbyHUKdO9jtEv7JsuH
rGii393rxEfaJWDuar7snCWomngqNjZercorc34GCr0rWG8CeO3fbQCfWdjsXmjv
ObYzmOTmyhQH/DmgUkN7cECovJ0EhTxJRJLT6FVLL3FUKuqyjb3PYoSRR1ACGOBY
IoCvi9xUjEFZQOPESoPBym3wNv9KXSWj7gdSNWLkd+p0OtLCypePz1ic9DIfCasK
Lqu13VD23pMv3IILpgyQ1NCoqDgj1qPiyizT9HKaZVr+EHD+SWDxtXnaOnOJ5RHv
wj4Z+dVhef5uCFoC3haehzLz5s5UuIl1Dyyfp8fAd0OU91BVQnm4LFg89+gCBfZK
8MhkzMyirWUINQeCu43SajsVczIz2yDZifaWXXIWKI2Ge6PnRLCcQnJH1pKn+Olv
ocwfqtPgXTirgSAFz1MBKaK0MEkGmoCwaeh2Q1605Xt6BAgbRk2TsaZPyclK4iD8
bJ9vsfSqMt0t9m3bBuIB141H6x4f/STSZcw8xg1K3pO0Bt83fO6YP3AD+hVlftbo
0+Cw/dQ7210DyG+3vMcA5Tjt+Z0pxsvmqE4NrJhUYiA0U2dPPpqyGo5wrXc/FcDj
FrF2NTEaVYTmj2h413nuipGJrZJTJus/R5+6P3+appkamYcDE5z3bDW9EhRk3LV5
mRsYKn9UOqPZrJoll+87
=5VPt
-----END PGP SIGNATURE-----

--ZmUaFz6apKcXQszQ--
