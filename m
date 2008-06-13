From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 17/19] ibmveth: enable driver for CMO
Date: Fri, 13 Jun 2008 15:25:02 +1000
Message-ID: <20080613152502.b2bebcf4.sfr@canb.auug.org.au>
References: <20080612215312.GF30916@linux.vnet.ibm.com>
	<20080612222311.GY30916@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__13_Jun_2008_15_25_02_+1000_H4c4uuvX8DHU8EgX"
Cc: paulus@samba.org, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Darrington <ddarring@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:55985 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbYFMFZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 01:25:09 -0400
In-Reply-To: <20080612222311.GY30916@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__13_Jun_2008_15_25_02_+1000_H4c4uuvX8DHU8EgX
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Robert,

On Thu, 12 Jun 2008 17:23:11 -0500 Robert Jennings <rcj@linux.vnet.ibm.com>=
 wrote:
>
> +	if(adapter->bounce_buffer !=3D NULL) {

Space after "if".  Here and elsewhere.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__13_Jun_2008_15_25_02_+1000_H4c4uuvX8DHU8EgX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkhSBK4ACgkQTgG2atn1QN9XtgCfdc+IB4X88HuALojEz80jJm1T
Vv8AoIyl4yui89WrCRb5rfMszOCLRCPf
=crz+
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Jun_2008_15_25_02_+1000_H4c4uuvX8DHU8EgX--
