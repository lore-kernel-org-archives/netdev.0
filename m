From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT] Networking
Date: Wed, 30 Jul 2014 10:36:28 +1000
Message-ID: <20140730103628.234a4036@canb.auug.org.au>
References: <20140729.165532.599552078692796545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/vZNXRzR5t3ARI/bC.RxbaY7"; protocol="application/pgp-signature"
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140729.165532.599552078692796545.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/vZNXRzR5t3ARI/bC.RxbaY7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 29 Jul 2014 16:55:32 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> Oliver Neukum (2):
>       cdc_subset: deal with a device that needs reset for timeout

This commit causes a build failure on arm (at least).  See my
linux-next email about this.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/vZNXRzR5t3ARI/bC.RxbaY7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT2D4MAAoJEMDTa8Ir7ZwV0lwQAIQWkSDPbAE0WOF8RcAat/fp
yOMGds/8lKJ28CWDC5OX2B0mIh8kRtbIcZQ6djZ8NSTfcXckLj9nOoTCl5mbNntc
fgvpN5hfSb/wgj4zBXvBqZm4ku7oAIbWHdXIfrojRv7AkMqwlB6bEtUFoOBAnLg7
76TfMZLC6jwsnqkmEhtlzWRKQNVA/Tjk40FiB0+AnoIaZ6MMzASBIMDe33fm2vJ3
9dld3SdY24x2TJBQP+sH4cjGacAzQ/4yilUhRZ1B7vvW4QOkhdV0FlfFie50e26a
XLHuP+7uhOV0ry/DecaE54oSUbKn/KNIURWoOSVbBUh65GX3lwBOMxhpfEJLXXbl
XEVAfa/pA5CZzy2dWgMlyIvMCkuFrvcAO5pbP93JQBObklBkHRbPgJu3Rx7f0Eh3
zzx7BNIwrNc34URRCVoNs0HfOi6a4OAKB7dFnNeVqHevP7K1g4MIBmUIBby+hVjn
slFqsDJDrDldBNdrumeX10b3BwzMKKWzyITQiglOcQW9LB4LhhRWxOWbEWHRVjZB
DfeLkJ82RK3HXCREE5GQAJqGviobCdCsdR8lPn7YggcatJpmozNcAZpRg1tzgSWy
FDCP4xBjzCrDOG14g2dyfw2mDluk7eM9RxRalAqVdjmEU/9U8Zh/1kcRK1S7VV9K
soYKCzH75SVJQNCyDX8J
=xSoZ
-----END PGP SIGNATURE-----

--Sig_/vZNXRzR5t3ARI/bC.RxbaY7--
