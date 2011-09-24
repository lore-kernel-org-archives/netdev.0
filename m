From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Fri, 23 Sep 2011 21:47:36 -0700
Message-ID: <1316839657.2182.136.camel@jtkirshe-mobl>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110917132153.GA32572@rere.qmqm.pl>
	 <1316476968.2184.14.camel@jtkirshe-mobl>
	 <20110923205621.GA27138@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-kHhLMNztwgkWflWysnRx"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62835 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062Ab1IXErh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Sep 2011 00:47:37 -0400
In-Reply-To: <20110923205621.GA27138@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kHhLMNztwgkWflWysnRx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-23 at 13:56 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, Sep 19, 2011 at 05:02:47PM -0700, Jeff Kirsher wrote:
> > On Sat, 2011-09-17 at 06:21 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> >> [patch finishing ixgb conversion to hw_features]
> > Thanks Michal, I have added the patch to my queue.
>=20
> I see that only a single driver left: igbvf. What's the status
> on its conversion?
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

Just waiting on validation at this point to verify the patch we have.  I
will see if I can get this patch verified and pushed asap.

--=-kHhLMNztwgkWflWysnRx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfWDoAAoJECTsCADr/EWUXVoIAIvizwTA+LVSPtgTWfD9b5lT
4JwpSqJy/OzalnTys4LKyr7A9ZQxxWmr0oKFv6JRjfRqve2u2eNVgAtYB6Mgw0A8
RAkhlwSsaOJpaSFgcW16A+qr+9X3AI3fB9RrWCpweWWcEUPnuT2SaErdBpkWpBoh
dHUDurH83vKepicTPVxTmhpNtUVl/xTyBYuKwt93HKgZEkTZLJ2HB4q3WaRPCOLi
T8rKE2WpF7bwKTTlxdc1dV0w8Z1GiKiDHYsZYV0oEZi9E09V1Q0aicwMagAyKgS0
uh0tlFMvpbp5iLq61/yitAqgs1AphmuktD0XTAO692b2xTQG1yjtnqr/Fm42zCE=
=gCtC
-----END PGP SIGNATURE-----

--=-kHhLMNztwgkWflWysnRx--
