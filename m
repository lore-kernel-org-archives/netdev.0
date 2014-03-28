From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v1] net-sysfs: expose number of link up/down transitions
Date: Fri, 28 Mar 2014 16:17:25 +1100
Message-ID: <20140328161725.e044dd9417cae3020068f350@canb.auug.org.au>
References: <cover.1395980768.git.decot@googlers.com>
	<cc4b88e880d31d8d71a5c8872a64c9d665cd097e.1395980768.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Mar_2014_16_17_25_+1100_TZFtd7YsdaL53_up"
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: David Decotigny <decot@googlers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44104 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbaC1FRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 01:17:33 -0400
In-Reply-To: <cc4b88e880d31d8d71a5c8872a64c9d665cd097e.1395980768.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__28_Mar_2014_16_17_25_+1100_TZFtd7YsdaL53_up
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

On Thu, 27 Mar 2014 21:35:00 -0700 David Decotigny <decot@googlers.com> wro=
te:
>
> Tested:
>   grep . /sys/class/net/*/count_link_*
>   + ip link set dev X down/up
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>

It is not a very enlightening commit message.  You should tell us why we
should add this to the kernel.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__28_Mar_2014_16_17_25_+1100_TZFtd7YsdaL53_up
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTNQXoAAoJEMDTa8Ir7ZwVrGkP/0Sw6YC2nHd10f6E4dfHE146
2hBS5ZGZqBJMlrbIXBvBO8BobyTGR0CU8AhD8yQeoQOFqC0+bdDbYg3Hb706LNNl
kmGOtr2pGX01GUOtELU408c+aVBBPvjajaaKgIrexfKKyhIhFC9Ike/TPPShWX5c
1qHj2+CtqfWK+Ep/3twNXOTpHcpNW3GEO1SOvldwWIRu6iSvcabqzVfCoZe4CRJl
nFLzuI2TeHEGKjno60K46tFuea9ia3DiQNOPoV8bHz9TmCtn02AAlM2ISSKSj8NB
SbGD8+3tc5Dgx8tlDZS0Wp0sOf4/+37HgiKNyWWNCdHnsnKN1J3pm4PkumDgNvLb
Ergv5hOQ6uCnWxbmZdXBk6nV/xtrEAVdh+oPU6l9d1rnsTxYLcjrJTRlpkLT38kD
uwNOeZZA54IxQLv4rJat78bWr8rEaQh5SQ3cuj4wfp56V0sclsMnDuRTqUiB7TAs
AxC/1PrxLfZwVfuxCW8F4qEZ7WMXDYOCrjP2urP+NR2tC/1MS5a64JVeXtNLkMM0
O5TdWqHyYVN9jlMhuT8q+/HOdn2NnGC2DSmvz65rw77pSuh4RHaSBg+snwdfNwmO
PS/dLhs9dO/el/n8NN5183lh4K2E863iacqPdiFPcaeVgJTUMMxvankQ6YrVirIR
3TJCVpoaobM5Cuf15kBZ
=OsAu
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Mar_2014_16_17_25_+1100_TZFtd7YsdaL53_up--
