From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: Shared i2c adapter locking
Date: Wed, 18 Nov 2009 07:59:17 +1100
Message-ID: <20091118075917.9ac0248c.sfr@canb.auug.org.au>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	<20091029154317.651904b9@hyperion.delvare>
	<1256828976.2827.27.camel@achroite>
	<20091105141122.56b6b4f8@hyperion.delvare>
	<1257429444.2793.2.camel@achroite.uk.solarflarecom.com>
	<20091105150715.692b5200@hyperion.delvare>
	<20091117193313.b750804e.sfr@canb.auug.org.au>
	<20091117103554.03971b2f@hyperion.delvare>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__18_Nov_2009_07_59_17_+1100_4c.670WErxsQBW.b"
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mika Kuoppala <mika.kuoppala-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Linux I2C <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091117103554.03971b2f-ig7AzVSIIG7kN2dkZ6Wm7A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__18_Nov_2009_07_59_17_+1100_4c.670WErxsQBW.b
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jean,

On Tue, 17 Nov 2009 10:35:54 +0100 Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org> wrote:
>
> Haven't you read this:
> http://www.spinics.net/lists/linux-next/msg07839.html
>=20
> and the 3 following posts?

Somehow I missed that, sorry :-(

> If you did and something is still not clear, please let me know. My
> understanding is that the action token is in David's hands now.

OK, I will await developments :-)

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__18_Nov_2009_07_59_17_+1100_4c.670WErxsQBW.b
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksDDqUACgkQjjKRsyhoI8ye2wCePBRJDwGffoAbkqiiTpm0cyFr
odwAn1zxSq7OJHHQ6zr6QdCUc1ZB8P4S
=wZxa
-----END PGP SIGNATURE-----

--Signature=_Wed__18_Nov_2009_07_59_17_+1100_4c.670WErxsQBW.b--
