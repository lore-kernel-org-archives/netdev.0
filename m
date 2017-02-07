From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v2 1/8] bpf: Use bpf_load_program() from the
 library
Date: Tue, 7 Feb 2017 21:37:33 +0100
Message-ID: <765bfbc6-8953-7e53-125b-cfe15e2171c3@digikod.net>
References: <20170206224941.14739-1-mic@digikod.net>
 <20170207.133551.1797238908531958057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SSpuc5ILhe5FXdN68AQHu1sDUiqSuCJaO"
Cc: linux-kernel@vger.kernel.org, acme@redhat.com,
        netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        shuah@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207.133551.1797238908531958057.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SSpuc5ILhe5FXdN68AQHu1sDUiqSuCJaO
Content-Type: multipart/mixed; boundary="erb73p73GwwmBAtqukrcbikPnS1teO5K2";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, acme@redhat.com, netdev@vger.kernel.org,
 ast@fb.com, daniel@iogearbox.net, shuah@kernel.org
Message-ID: <765bfbc6-8953-7e53-125b-cfe15e2171c3@digikod.net>
Subject: Re: [PATCH net-next v2 1/8] bpf: Use bpf_load_program() from the
 library
References: <20170206224941.14739-1-mic@digikod.net>
 <20170207.133551.1797238908531958057.davem@davemloft.net>
In-Reply-To: <20170207.133551.1797238908531958057.davem@davemloft.net>

--erb73p73GwwmBAtqukrcbikPnS1teO5K2
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Right, it was a batch of miscellaneous patches at first but I split them
in three series. I'm going to resend this patches in two v3 series (with
cover letters): one for each tree (net-next and perf).

Thanks,
 Micka=EBl

On 07/02/2017 19:35, David Miller wrote:
>=20
> Please post your patch series(s) with proper "[PATCH ... 0/N]" header p=
ostings.
>=20
> Thank you.
>=20


--erb73p73GwwmBAtqukrcbikPnS1teO5K2--

--SSpuc5ILhe5FXdN68AQHu1sDUiqSuCJaO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliaMA0ACgkQIt7+33O9
apVOCQf8CrCbp0Z057ALGdy71+tKlARbOViWZgfNtqrbOOV8yoLgkXejy6ggp9u9
YB5Abfy1NwxmrOxEQAy47GO6FNh+Tj8b6jHaR2UvAj12IyG5XaK8gmnv8M2lSRj2
CvrDdoQnDeJUoqsT1my9QWth0H9zLqD7o3ktAC0O1h9sZ5LivqyqaNXRk7rWZkLg
jwqqRozndk9uwtRFBoEy5EgWbUmtYQW9uSUsu5HlkkLaiB1d6mWqLHkzesOTqx24
aUm0dYdNtkl5KGd6bvjtANlFh6D7gz+iXamC4ZaeKbFhaBMi42NZddkt5fojNctP
XoM2d0KkGm4Zh5ULrmzQkshTd0g4PQ==
=tV0L
-----END PGP SIGNATURE-----

--SSpuc5ILhe5FXdN68AQHu1sDUiqSuCJaO--
