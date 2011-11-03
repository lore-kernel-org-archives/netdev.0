From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: wireless git trees returning to kernel.org
Date: Thu, 3 Nov 2011 12:15:00 +1100
Message-ID: <20111103121500.9860d492843915cc21bcfdab@canb.auug.org.au>
References: <20111102180946.GC12168@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__3_Nov_2011_12_15_00_+1100_CWfh6kjizqrlHXFC"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111102180946.GC12168-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__3_Nov_2011_12_15_00_+1100_CWfh6kjizqrlHXFC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

On Wed, 2 Nov 2011 14:09:46 -0400 "John W. Linville" <linville-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org=
m> wrote:
>
> I have migrated the wireless git trees back to the kernel.org
> infrastructure.  As of right now, the trees are identical between
> kernel.org and infradead.org.  Further updates likely will only go
> to kernel.org, so plan accordingly.
>=20
> The "current" wireless tree is here:
>=20
> 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git
>=20
> The "next" wireless tree is here:
>=20
> 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git=
\\

I have switched to using these.  I also renamed the tres in linux-next to
match your names (so "wireless-current" has become "wireless" and
"wireless" has become "wireless-next").

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__3_Nov_2011_12_15_00_+1100_CWfh6kjizqrlHXFC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOsesUAAoJEECxmPOUX5FEuFIP/A1tB55F5auHv0qMAdkpPHtv
FSNVw234OGcoTxrUqm6sZC7xWvTgnzbsDrPsXlz/cRdKonMuVVHs1MPbfmWkDjTP
UgPG1RhI5hF0TYWH/qU27fiFWTdGmRAzfkJLd5VKAlRsFSIQTJ//FSKTwRXCp3v4
8vnk5a5B0PkdgEuPn8fXGscxvACkiFXwap7+qBxAebyX7ONda2vFWjT9NfqNu4de
pYf8MhrvafAl8kFQnxJbWlY1Ry0JyH+k0fu2wrRnq7BDRu+H7G3oR9BEbqkMkQbT
/Bl8UNw3RcVDgHcSkQ/UnQXMLhc1qEjBH2O+7U/TMazbcJ2mnkDj5ayCPMXr6d0a
y4tep+5NadYN/SLh3/5W1kFnYLzRxi76Sfd7mBL+x9A+daUBP5idrqi+Cxcssht5
/ysEvBSoIDY/7+ILy+Cpt9aB1//3nr9hlR7zQx2Bohy1CK2/bK1AxcSf/We9DJ1w
VbzPCbiKFcHhGigbkBu6qhl1QaDMwEAsqABXDrhlaVXN74S0CZZc0nlOUYjm0z3Q
OBiwEOvLJ2CJ2s0hRajuhDEZ5miZwy9y3pIQgYtx7DhhhEw4SaNdnC+cZhMZBhZE
JAEHCCnpZKnxbjJhZBPghMH8MmeTnFf9JgnzevLGscwxVhlOCSbLHz3z/5hmySKT
LJWF1ylcthXpRTfpT8gI
=tBTX
-----END PGP SIGNATURE-----

--Signature=_Thu__3_Nov_2011_12_15_00_+1100_CWfh6kjizqrlHXFC--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
