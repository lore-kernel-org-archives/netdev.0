From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sun, 16 Sep 2007 01:00:37 -0400
Message-ID: <200709160100.48055.flamingice@sourmilk.net>
References: <200709152017.02646.flamingice@sourmilk.net> <200709160047.45128.flamingice@sourmilk.net> <20070915.215053.74746915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8097998.hlQ87qHbmv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070915.215053.74746915.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart8097998.hlQ87qHbmv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 16 September 2007 00:50, David Miller wrote:
> From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
> Date: Sun, 16 Sep 2007 00:47:40 -0400
>
> > Huh? How does a driver use NAPI if it can't pass a struct net_device?
>
> It is now managed by a struct napi_struct which you can embed into any
> object you like.
>
> NAPI is now totally disconnected from the network device structure.
> This was necessary for proper support of multi-queue cards.
Ah, very nice.

-Michael Wu

--nextPart8097998.hlQ87qHbmv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBG7LiAT3Oqt9AH4aERAlQBAKDYllqzSaN4FMKHcWt40T3P4aDFkwCfZZQD
+Iw30pC/cd2UBldOSQLSEwI=
=cYB4
-----END PGP SIGNATURE-----

--nextPart8097998.hlQ87qHbmv--
