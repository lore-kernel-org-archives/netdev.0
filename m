From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for bnxt_re V4 00/21] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 07 Feb 2017 10:27:35 -0500
Message-ID: <1486481255.86943.7.camel@redhat.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-7elQFtwnDxwIN98mdbiS"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-7elQFtwnDxwIN98mdbiS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-12-21 at 03:41 -0800, Selvin Xavier wrote:
> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50G RoCE HCAs.
> This driver is dependent on the bnxt_en NIC driver and is
> based on the bnxt_re branch in linux-rdma repository.
> bnxt_en changes required for this patch series are already
> available afore mentioned branch.
>=20
> These changes are available for your reference in
> the bnxt_re_v4 branch of following repository.
> https://github.com/Broadcom/linux-rdma-nxt/
>=20
> Doug,
> =C2=A0This patch set has the file name related changes suggested
> =C2=A0by you. Please let us know your other feedbacks as and when
> =C2=A0you are ready.
>=20
> Thanks,
> Selvin Xavier

Hi Selvin,

I've reviewed v4. =C2=A0Aside from the comments I made on patch 03, and som=
e
head scratching I did on patch 16 that I think I got figured out (I was
concerned that budget might get modified by two places without adequate
protection, but I think I see now that that can't happen), and the
comments Leon made in his reviews, things look fairly reasonable.
=C2=A0Please spin up v5 and post to the list.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-7elQFtwnDxwIN98mdbiS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYmednAAoJELgmozMOVy/daM8QAJa9ebnq6rg1VT2EQG8Qqx4f
JWAOINff4Me2wR1A0ez24bDTbyOuCisBFHS9QUXnq2+Ub9F2TMk/3nFVXB0w4QXQ
EyjFjt4vYpssUkSORwq3v0F1S8Xb6r8wpArvq/5BfkPeiGDimtn6xERaazNCOxkf
l5Hm5cTOMQtxqpxnJeQOWHHmP3sRUB3m+8T9S4iAkM/HnTer3Tlb/bKVA4dprzBs
9gZsNaKpZmgt/7s22jpQXYf1qJ/NlapyCJuIXNll4yyQ/WuRd2156NEg0eIX81Za
mOMrKuOH+hckGGXbpNXThFwx592w8WO9N9YJXwN8ypMAxOF8S60Jx6fMGEODEaGv
orUd+66/f9r3e1PW48rqtKWmFDOjpNDyCJjSt4mNpVExroxY60eFJ9HC2oCLYcpm
QPvRGmeSOrNPEaSHbjq48/u22YH2MXZMRJR+qio5LMVDNX2Sw/nGjDnWS+Ktpvmy
LwAlVD55Q1EmQubrvJZjKhoCHno4QmdtvYKFRJCxKMNyyd2oekzQZTN3oR+rfR6m
o/nsjPyykVewOTjW51KyLLRcGu91jhDc4NHCgLzSJOORe4wtLfIN66ONKpiRykZC
5H6jC7O3xGjRXqWrtcyoy8VpHkC3P7h/zF/Izz5a6bQVLP3jqd8OYPA8IkDpufyX
ND8dYyAd1gnjnf4AnXVr
=YXbA
-----END PGP SIGNATURE-----

--=-7elQFtwnDxwIN98mdbiS--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
