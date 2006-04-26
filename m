From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/17] d80211 patches
Date: Wed, 26 Apr 2006 23:27:15 +0200
Message-ID: <200604262327.21081.IvDoorn@gmail.com>
References: <20060421220951.205579000.midnight@suse.cz> <20060421225210.36a0225b@griffin.suse.cz> <20060426193907.GB7922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3510809.7MGdPkGeaC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:54649 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S964879AbWDZV0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 17:26:18 -0400
Received: by nproxy.gmail.com with SMTP id x37so1228967nfc
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 14:26:17 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060426193907.GB7922@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3510809.7MGdPkGeaC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 26 April 2006 21:39, John W. Linville wrote:
> On Fri, Apr 21, 2006 at 10:52:10PM +0200, Jiri Benc wrote:
> > On Fri, 21 Apr 2006 22:52:08 +0200, Michael Buesch wrote:
> > > Can you please send your hacky patch for the bcm43xx
> > > to me, so I can come up with a clean one?
> >=20
> > Sure, actually I planned to do it in a few minutes :-)
>=20
> Hacky or not, I'm applying this patch to keep the bcm43xx driver
> from breaking.  I don't suppose you have a patch for the rt2x00 driver?

Hi,

I had promised to create this patch before, but due to shortage of time
hadn't managed to do so. At the moment a compatibility fix for the updates
is already present in our CVS tree.
I am already working on a patch series to send for wireless-dev to bring rt=
2x00
up to date. The change for compatibility for the stack is update is also am=
ongst the
patches. I am still working on the final patches for the series, but will b=
e able to
send all (+/- 30 patches) tomorow.

After that I hope to send new patches for rt2x00 on a more regular basis,
to prevent large patch series like this one to be send in a single day.

IvD

--nextPart3510809.7MGdPkGeaC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBET+W4aqndE37Em0gRAtU1AJ9OLLf200DBNd6c1jWnoOr2O1P8OwCghFc5
ZA/uf6rqanRcZOi8JP0bC+8=
=kvhi
-----END PGP SIGNATURE-----

--nextPart3510809.7MGdPkGeaC--
