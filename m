From: Valdis.Kletnieks@vt.edu
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 02 Dec 2007 14:56:42 -0500
Message-ID: <18773.1196625402@turing-police.cc.vt.edu>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com> <47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill> <20071201163035.321fd554@freepuppy.rosehill>
            <20071202135104.006c5a15@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1196625402_2962P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:34462 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbXLBT50 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 14:57:26 -0500
In-Reply-To: Your message of "Sun, 02 Dec 2007 13:51:04 GMT."
             <20071202135104.006c5a15@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1196625402_2962P
Content-Type: text/plain; charset=us-ascii

On Sun, 02 Dec 2007 13:51:04 GMT, Alan Cox said:
> On Sat, 1 Dec 2007 16:30:35 -0800
> > I spoke too soon earlier, ndiswrapper builds and loads against current
> > 2.6.24-rc3. Vmware and proprietary VPN software probably do not. Once again I don't
> > give a damn, but the enterprise distro vendors certainly care.
> 
> Enterprise distro vendors ship kernels from the 2.6.19 era, so I don't
> see why they care.

They don't care *now*.  They will care when they try to rev forward from .19.

Not that they'll care a *lot* - it took *me* all of about an hour to get VMware
Server 1.0.4 working under -rc3-mm2.  Probably will take an enterprise distro
4-5 hours, 30 mins for the port and 4 1/2 hours for the paperwork. :)


--==_Exmh_1196625402_2962P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHUw36cC3lWbTT17ARAh78AJsFA/XnhYVcpqEs53gLjRoyy27dBwCgipGy
Xrzb5Kga0xxwCYiL71ViNN0=
=IJ+U
-----END PGP SIGNATURE-----

--==_Exmh_1196625402_2962P--
