From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Mon, 3 Jan 2005 16:56:53 -0600
Message-ID: <200501031656.57041.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2723897.nnnOR6FQuA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2723897.nnnOR6FQuA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

How would I check?  It should be in the hundreds of thousands.

On Monday 03 January 2005 04:51 pm, Stephen Hemminger wrote:
> On Mon, 3 Jan 2005 14:55:24 -0600
>
> "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:
> > Any insights as to why there would be such a stark difference in
> > performance between V2.6 and V2.4?
>
> How many flows are going through the router? The neighbour cache
> can get to be a bottleneck. Perhaps Robert "the Router Man" Olssen can
> give some hints.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2723897.nnnOR6FQuA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB2c24qtjaBHGZBeURApfPAJ47JnVz3gwRijJDhfR02fR2zCDrkgCgk+K0
lVInjqbgrTXWPVwsKyMdWzA=
=cpIW
-----END PGP SIGNATURE-----

--nextPart2723897.nnnOR6FQuA--
