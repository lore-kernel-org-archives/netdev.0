From: jhf@columbus.rr.com (Joseph Fannin)
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Sat, 18 Nov 2006 06:24:39 -0500
Message-ID: <20061118112438.GB15349@nineveh.rivenstone.net>
References: <455B63EC.8070704@madrabbit.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kORqDWCi7qDJ0mEj"
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Bcm43xx-dev@lists.berlios.de, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-05.ohiordc.rr.com ([65.24.5.139]:30080 "EHLO
	ms-smtp-05.ohiordc.rr.com") by vger.kernel.org with ESMTP
	id S1755952AbWKRLZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 06:25:15 -0500
To: Ray Lee <ray-lk@madrabbit.org>
Content-Disposition: inline
In-Reply-To: <455B63EC.8070704@madrabbit.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 15, 2006 at 11:01:00AM -0800, Ray Lee wrote:

> I've come back to my laptop being mostly dead after hours of it being off on
> its own (twice now). Mostly dead meaning the keyboard is nearly
> non-responsive, but the mouse works great (I'm in X, of course). I say 'nearly
> dead' as sysrq-t,b works, so I'm sorta stumped there. (x-session seems to use
> netlink, so perhaps that's the connection? ctrl-alt-f[1-7] don't do anything,
> however.)

    This sounds like what my laptop was doing in -rc5, though mine
didn't take hours to start acting up.

    I *think* it was the MSI troubles, causing interrupts to get
lost forever.  Anyway, it went away in -rc6.

    I don't have the broadcom hardware.

--
Joseph Fannin
jfannin@gmail.com || jhf@columbus.rr.com


--kORqDWCi7qDJ0mEj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFFXu121/BPLCVlRuARAo1rAKCoqAGZmIEOKxvGammQ7Jndeq+56gCfe6kI
/vXcf3d19VuTO7AdvjcJtJ4=
=HXJQ
-----END PGP SIGNATURE-----

--kORqDWCi7qDJ0mEj--
