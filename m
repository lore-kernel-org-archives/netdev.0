From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net tree with the scsi tree
Date: Thu, 30 Jun 2011 14:41:19 +1000
Message-ID: <20110630144119.1bff2ccb.sfr@canb.auug.org.au>
References: <20110630123325.43268067.sfr@canb.auug.org.au>
	<4E0BF998.7030800@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__30_Jun_2011_14_41_19_+1000_spVF7eu+vTdA9kMf"
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"James Bottomley" <James.Bottomley@HansenPartnership.com>,
	mchan@broadcom.com
To: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:59744 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725Ab1F3El0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 00:41:26 -0400
In-Reply-To: <4E0BF998.7030800@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__30_Jun_2011_14_41_19_+1000_spVF7eu+vTdA9kMf
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Bhanu,

On Wed, 29 Jun 2011 21:20:40 -0700 "Bhanu Prakash Gollapudi" <bprakash@broa=
dcom.com> wrote:
>
> Stephen, can you please send the conflicts? Most probably you should=20
> have seen the conflicts w.r.t version number in bnx2fc.h and date in=20
> bnx2fc_fcoe.c.  If that is the case, the versions from net tree are good.

Yes, they were exactly the only conflicts I got.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__30_Jun_2011_14_41_19_+1000_spVF7eu+vTdA9kMf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOC/5vAAoJEDMEi1NhKgbsb5gH/1qiNAZ348iQ0iqH2UXTnfkv
0XhQZAnyFzMpoJHLQjELJLRTCOp6XeRxJtAKbRFhdrgYM/fmTLtzC2VQ/AnvnUja
yN501XW23ndQOhNYRoUMQMehNFeNnr7XkKzUlKGjuydQFtGaYB1GN4QAjW64XZhX
ob9QrkjUP1UcAY4HLqCEs0EsyX0e2XuqT8Q5NHS8sZPxatJ8i1UytzYRRWgXVPxb
em476hKBs5w0/yQXkPjizrI8gEKaqd+AeZd8dDTC4+//8hm363AQ4WHJNJ/2l7u7
2JCdgPY+xaOy5DHru8HjFajfNY5wNagutC6phe9c+sn84fYB4AEJwyO3083WLvE=
=ynvR
-----END PGP SIGNATURE-----

--Signature=_Thu__30_Jun_2011_14_41_19_+1000_spVF7eu+vTdA9kMf--
