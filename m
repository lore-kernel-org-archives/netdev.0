From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Mon, 31 Jan 2005 14:42:18 -0500
Message-ID: <200501311942.j0VJgIYs016952@turing-police.cc.vt.edu>
References: <1106932637.3778.92.camel@localhost.localdomain> <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net> <1106937110.3864.5.camel@localhost.localdomain> <20050128105217.1dc5ef42@dxpl.pdx.osdl.net> <1106944492.3864.30.camel@localhost.localdomain> <1106945266.7776.41.camel@laptopd505.fenrus.org> <200501290915.j0T9FkVY012948@turing-police.cc.vt.edu>
            <20050131165025.GN18316@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1107200537_32560P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
        Lorenzo =?iso-8859-1?Q?Hern=E1ndez_Garc=EDa-Hierro?= <lorenzo@gnu.org>,
        Stephen Hemminger <shemminger@osdl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
        Hank Leininger <hlein@progressive-comp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: Your message of "Mon, 31 Jan 2005 17:50:25 +0100."
             <20050131165025.GN18316@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_1107200537_32560P
Content-Type: text/plain; charset=us-ascii

On Mon, 31 Jan 2005 17:50:25 +0100, Adrian Bunk said:
> On Sat, Jan 29, 2005 at 04:15:43AM -0500, Valdis.Kletnieks@vt.edu wrote:

> > Note that obsd_rand.c started off life as a BSD-licensed file - I was told
> > that was a show-stopper when I submitted basically the same patch a while back.
> >...
> 
> At least the three clause BSD license is GPL compatible.

The copy of obsd_rand.c I have hass the problematic 4-clause version.  It looks
to me like we'd need to get Michael Shalayeff, Theodore T'so, and Niels Provos
to all agree to re-license under the 3-clause variant.  Using Arjan's code is
most likely the better approach...

--==_Exmh_1107200537_32560P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFB/ooZcC3lWbTT17ARAgbcAJ0Qn3ivh/rz9hIRaA4/ZaB4oZrx9wCdGXJL
VqYqh5yoLkS51NMtBgzmfys=
=rgm9
-----END PGP SIGNATURE-----

--==_Exmh_1107200537_32560P--
