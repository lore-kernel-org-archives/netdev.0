From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v1 0/7] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Sun, 04 Jan 2015 21:55:40 +0000
Message-ID: <1420408540.5686.140.camel@decadent.org.uk>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EaGTxCSLF3yufiF+QolH"
Cc: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Masatake YAMATO <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420405017-23278-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-EaGTxCSLF3yufiF+QolH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-04 at 12:56 -0800, David Decotigny wrote:
[...]
> I can send updates to other drivers, even though it's rather pointless
> to update 1G drivers at this point for example. Please let me know,
> but I'd prefer to do this in follow-up patches outside this first
> patch series.
[...]

They should be changed to ensure they reject setting any of the high
advertising flags, but it's not urgent.

Ben.

--=20
Ben Hutchings
This sentence contradicts itself - no actually it doesn't.

--=-EaGTxCSLF3yufiF+QolH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVKm24ue/yOyVhhEJAQrwKhAAk00wT5jw0b2eHJxy42xW75K6WbAmy4wk
bc9QZfqzAoxmOjZ37/x99bzrbEFwHCvMeNifNzbGaX+pSgZhHfdlu3en2LULp8+r
ovZV6SXcYDBn1w+vsSZ1EEFNjeME3JFRMp7WM9y+UJrw1OsIsl0DylyjCSYvezgV
Lkv/cF2mVPKfUgAjwZzQP/m5zFcb2Ng+elozwvdoXCITCzw8OTkI9mHvqX40Cai9
690+CBHJCdzAygS/ibVTV7PDwjuVRhwu5z0fxU064+252YbqSl1AXsUYLzvQjX4/
a5a5QdlUU96eK564Lc8rPmesS+qY5cWbpBe5+yWBnNWHdC/uPM0CKjTwtfN+GqAX
ooXtSnWpFO4psOJJIEHFCboxsQGx0ydH9pKq/G1NqDw8I2SAp6rCtW6hdqOW2OpA
i7TNt3AcRUybfujOkfDQIetDXpri9PXConFf4XHhex0Fg2zFAA5zi6I1HzhBi6Op
9G8dxfrYO+Q9xotouOCz6jH8N26VF5m+deyx+/nC3lHD4D1TxboTIjaPM2tSBHiG
Op+ViVyG/ZwI1jaVObC1lB7pMWiIg6icxXrVvtTir0KcAX9xAGxqTu50FD8eNJp2
4r9Dg83dLWyzNcsljrO4As4QnMews9UdoD0iTAZQam62G1PeyjAFoIOSOJC2Iz+l
+1h5swgNXec=
=PMb/
-----END PGP SIGNATURE-----

--=-EaGTxCSLF3yufiF+QolH--
