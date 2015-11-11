From: William Dauchy <william@gandi.net>
Subject: Re: regression in ixgbe SFP detection patch
Date: Wed, 11 Nov 2015 22:34:58 +0100
Message-ID: <20151111213458.GD3641@gandi.net>
References: <20151111173527.GA3641@gandi.net>
 <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Cc: William Dauchy <william@gandi.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:38405 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752274AbbKKVfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 16:35:01 -0500
Content-Disposition: inline
In-Reply-To: <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov11 20:33, Tantilov, Emil S wrote:
> If the diff above is the patch you are referring to then you will break t=
he
> SFP+ detection in the case where the driver was loaded while there were no
> SFP+ modules present in the cages.

understood, I was surprised of the modification of behavior.=20
--=20
William

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZDtIIACgkQ1I6eqOUidQHBYwCfZpMzVYJT9/3irrA6wpCy2GaE
qyYAnjCP8FdkPV7QUJrgzhOC7TP/acc5
=Uv7s
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--
