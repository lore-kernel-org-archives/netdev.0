From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 19 Apr 2013 18:13:34 +1000
Message-ID: <20130419181334.3e042702caa9c2ad9171b4c2@canb.auug.org.au>
References: <20130419132127.05ea53adec329ca794d62be7@canb.auug.org.au>
	<20130419073409.GH20819@ritirata.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__19_Apr_2013_18_13_34_+1000_e2CbsKAP_mvcYz.V"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Martin =?UTF-8?B?SHVuZGViw7hsbA==?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	b.a.t.m.a.n@lists.open-mesh.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130419073409.GH20819@ritirata.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__19_Apr_2013_18_13_34_+1000_e2CbsKAP_mvcYz.V
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Antonio,

On Fri, 19 Apr 2013 09:34:09 +0200 Antonio Quartulli <ordex@autistici.org> =
wrote:
>
> Your patch looks good, but I'd prefer to send my already prepared pull re=
quest.
>=20
> Is it ok with you?

Its entirely up to Dave how/if he fixes this up.  He could just leave it
to Linus, though he would usually pull the net tree into the net-next
tree after Linus merges the net tree - in which case, this should be
fixed in that merge.

i.e. ask Dave :-)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__19_Apr_2013_18_13_34_+1000_e2CbsKAP_mvcYz.V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRcPyuAAoJEECxmPOUX5FEXtQQAKhPfqx7n2tBZ/1BM2g3rXRZ
ltM4N9ueIWnvzLnfOwdoBEsWmgZ1RjhTx7/kxEla02hUw69VrHtpmo5aYZmu2vcl
bx9jiOzPk3FEGSmbsQyV6gnRBuyA6KwwpkUNF7VApdUzaTnd+qBAT0cRf1T/l5PN
Nn6VjxVg4fnfqsy1FhOhPuTV8xE7t/sVRpY46jLSQdMGpNWQo7ro/bbwchdEFFgI
E1Iqf+BKBTBd77ckW4Wr8kGOdBLawBMcuR9sMQPpxWhfkxYGD84bZPQ7npqxk6j4
h03svuHcYl6OkJorjtc4e8j7MiH6wLMukjOlgGoEuRO4lHjqUHq6cHRQvFZwNZ16
VkZzejJ5itg9v1C+mIykk9F6igncBm7T7GSzz3MvADhrjvRZuFkGw0PCXTGU0Bpe
iyYUA5LapCtTcc8vvIULyDvAIaPrNP/hPoG3d3JhFAbTkom5xQjNQDlyb4BQmVtT
6NxEu7HKGR6nbwypWcgjV0mjDq+prgHsGXWV20gQPlh9BOQ0RZOTscIIDL2Pq6mw
RZQnbKOVVleFe4RV0yztjaynS1atH2GkVSZnNIvug1+MSMBqGqZzNpwT2HkZrWLm
tef+yqe3fcU9WG9jhdyH4otdDuTnvUxy3mOXjHIbZzz3+P83s841YVIW+b/O7tzv
R+nAToOPGvv+ifMyREuB
=lkP4
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Apr_2013_18_13_34_+1000_e2CbsKAP_mvcYz.V--
