From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 14 Mar 2011 16:31:35 +1100
Message-ID: <20110314163135.f366742e.sfr@canb.auug.org.au>
References: <20110314152456.b49b2693.sfr@canb.auug.org.au>
	<1300078778.3962.22.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__14_Mar_2011_16_31_35_+1100_OF5Z5OjPr12D0VX_"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300078778.3962.22.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__14_Mar_2011_16_31_35_+1100_OF5Z5OjPr12D0VX_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ben,

On Mon, 14 Mar 2011 04:59:38 +0000 Ben Hutchings <bhutchings@solarflare.com=
> wrote:
>
> Commit cd7eab44e994 ("genirq: Add IRQ affinity notifiers") was a
> prerequisite for some changes in networking.  Thomas Gleixner applied it
> on a branch of its own so that David Miller could pull just that commit
> into net-next-2.6.  Of course, this means net-next-2.6 doesn't have the
> later fix (and won't for a while).

Yeah, but Dave merged that into the net-next-2.6 tree some time ago
(late January) and it hasn't caused a problem in my builds until now.
Maybe some config option changed ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__14_Mar_2011_16_31_35_+1100_OF5Z5OjPr12D0VX_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNfag3AAoJEDMEi1NhKgbsBPAH/A32R+7WyaWanoLBdfmPVhgk
vtq7ylxJOIYaL9o6JTolmik6LUr9k+VHi0eya3mziaRJXtzQH9g8xe/APMS+SNus
cZTZV7i8Zm5lBhqZctJ5+xKC14AnbzqTfamxdvMag3Vf9/EYCMp7/0cScFpRcv51
zytXv+5GZuMeATeRLeWT9Cz6J3Tk+lckePwz7/TEtBp4DTTkXh42UYOOCJfWPdM5
d0RpADtE7CBlLhYaHa+EOEV8/EzlhdKMi+M4Gq3tRRv96D7FnmuyWaIHvuu4Pi18
k7jtU/et1eUQ6xMFlGKxv+gZnXf+JyREW1Ely+hk8Lves8B4uoza9HZsutWS84w=
=PAf8
-----END PGP SIGNATURE-----

--Signature=_Mon__14_Mar_2011_16_31_35_+1100_OF5Z5OjPr12D0VX_--
