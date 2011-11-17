From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 5/5] net-next:asix: v2 update VERSION only
Date: Wed, 16 Nov 2011 22:18:57 -0500
Message-ID: <5923.1321499937@turing-police.cc.vt.edu>
References: <1321318357-17723-1-git-send-email-grundler@chromium.org> <21257.1321403368@turing-police.cc.vt.edu>
            <CANEJEGtnUS5B1ggdoPn8gcCbFm==dfgHCgXVgcgpuooFUAowJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1321499937_2949P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 15 Nov 2011 17:37:47 PST."
             <CANEJEGtnUS5B1ggdoPn8gcCbFm==dfgHCgXVgcgpuooFUAowJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1321499937_2949P
Content-Type: text/plain; charset=us-ascii

On Tue, 15 Nov 2011 17:37:47 PST, Grant Grundler said:

> Upstream drivers are routinely back ported to distro releases. Version
> is the primary means for a vendor (like ASIX) to determine what was
> back ported. Distro maintainers and 1st tier support organizations
> also need to track versions and "ethtool -i" is the canonical way to
> look this up on a running system.

Oh, OK.  I figured the distro would know what they backported based on the
kernel version they generated - I forgot that sometimes users will bypass the
distro and go to the upstream vendor, and you may not know what their distro
had done...


--==_Exmh_1321499937_2949P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOxH0hcC3lWbTT17ARAou4AKCq7QNRGeE3On+xkRFF8cTaxLPqbQCdEUlZ
9JNfZMRCVtSkj2nwN9HVJUQ=
=cMmn
-----END PGP SIGNATURE-----

--==_Exmh_1321499937_2949P--
