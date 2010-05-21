From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the driver-core tree with the net
 tree
Date: Fri, 21 May 2010 16:49:26 +1000
Message-ID: <20100521164926.2c63c442.sfr@canb.auug.org.au>
References: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
	<m1tyq1wy4h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__21_May_2010_16_49_26_+1000_QP67q2TFJRByna.R"
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <m1tyq1wy4h.fsf@fess.ebiederm.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_May_2010_16_49_26_+1000_QP67q2TFJRByna.R
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Thu, 20 May 2010 23:46:22 -0700 ebiederm@xmission.com (Eric W. Biederman=
) wrote:
>
> It looks right, except perhaps the RPS code looks like it will cause a
> build failure with sysfs disabled, but that has nothing to do with your
> changes.  I don't see any real conflicts here, just two patches passing
> very close to each other.

Thanks for the confirmation.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__21_May_2010_16_49_26_+1000_QP67q2TFJRByna.R
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkv2LPYACgkQjjKRsyhoI8yyYgCZAZH74AlUEJnznwNszJjYMoj/
ESMAnRhsbTRi2j/4OidK0IaqdQu3eMse
=lNWI
-----END PGP SIGNATURE-----

--Signature=_Fri__21_May_2010_16_49_26_+1000_QP67q2TFJRByna.R--
