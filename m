From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Tue, 4 Jan 2005 09:07:03 -0600
Message-ID: <200501040907.07466.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2323836.npItmXt88H";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2323836.npItmXt88H
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 03 January 2005 04:51 pm, Stephen Hemminger wrote:
> How many flows are going through the router? The neighbour cache
> can get to be a bottleneck. Perhaps Robert "the Router Man" Olssen can
> give some hints.
Tue Jan  4 08:59:12 CST 2005
58406 rt_cache
Tue Jan  4 08:59:48 CST 2005
60636 rt_cache
Tue Jan  4 09:00:34 CST 2005
63891 rt_cache
Tue Jan  4 09:01:02 CST 2005
64635 rt_cache
Tue Jan  4 09:01:29 CST 2005
65689 rt_cache
Tue Jan  4 09:01:58 CST 2005
63426 rt_cache
Tue Jan  4 09:02:25 CST 2005
64139 rt_cache
Tue Jan  4 09:02:53 CST 2005
63860 rt_cache
Tue Jan  4 09:03:20 CST 2005
65719 rt_cache
Tue Jan  4 09:03:48 CST 2005
62465 rt_cache
Tue Jan  4 09:04:15 CST 2005
39339 rt_cache



=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2323836.npItmXt88H
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB2rEbqtjaBHGZBeURAqWAAJ9KZYqLRuAig+bKL6/MT9R9/hWuigCeOip1
XyXwql9OqQ4OWxV5aRYM06g=
=HPlF
-----END PGP SIGNATURE-----

--nextPart2323836.npItmXt88H--
