From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/5] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Fri, 05 Jun 2009 08:52:17 +0200
Message-ID: <1244184737.22576.94.camel@johannes.local>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-zhkfR7yzDtOADSFsCaNU"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244168990-28355-4-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-zhkfR7yzDtOADSFsCaNU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-06-05 at 06:29 +0400, Dmitry Eremin-Solenikov wrote:

> +/* This source file is shared between kernel and userspace sources, thus
> + * a bit of __KERNEL__ checks
> + */
> +#ifdef __KERNEL__

It's a C file. It can't be shared expect by copying, hence IMO these
things are pointless.

johannes

--=-zhkfR7yzDtOADSFsCaNU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKKMCeAAoJEODzc/N7+QmaOkYP/2WkkWFvXl+8pgzsvjTkyRj/
J9jTDFnigkCNmFd07/fOageIoQJzUNasgXbzEPyXGrF7r6iVVj4sInSKmuBBCrMp
wXwF0qzkRTGVfhL2jDdb80DUjZlavEajFXqTOMV66VE82QHUkPAuklscOKjy+LQU
c49IkqI7IPglQYMoA8Rae0EPSzcLig/rHiMMwjGK/3eVS4/Yp0jKLjdRITVOZNiy
O6oh7sABcWEiZ6T73c9WfTlnwL9qJrQZp5GvLrGx0JwkElw+JMX/2/PKpcYIkBUl
rkwm/57RMIrNp3aBoofceLSxK+FQca++CgqzcOnObXVaU3s+Zfw4/8NXRq38riY7
/bVsaXgk4Af6M7qoz/d3GwkbxUn1TcTwluBqeTo6hDKk1rt5KDEWOYeTuNj5rDxW
1PrIVSW7dnrwpaM27LHKzxHByC3uHg/xoqmuLj67L+OpPkbN9OXWx6LMoMId8ihY
CDWhEtTHTgwATXhGOBoQ/tz9iqS2E26Wbp6Fd5Od89VQ/sx0EEWFnh/j+Tz8b84E
hyiezLkOsT9hn0Z2K3KuNKpdZ5UFfXDvRO4UVaSo7DtN3p9aXpM+4K858TMb0gaZ
jR2MDMpy/OtcuiugKXvftP7C8xLd4g9UZct5nIBUXKDTJo+lseZ8FB5pnmpB5quz
D0YJorA+lakschrhBCZ6
=5I1f
-----END PGP SIGNATURE-----

--=-zhkfR7yzDtOADSFsCaNU--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
