From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/6] rt2x00 update
Date: Fri, 28 Apr 2006 16:52:20 +0200
Message-ID: <200604281652.24028.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2922498.NklX4tOok5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:61151 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030374AbWD1Ov3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:29 -0400
Received: by nproxy.gmail.com with SMTP id n29so1594528nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:28 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2922498.NklX4tOok5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

Here is a small update for the rt2x00 drivers in the wireless-dev tree.
They all contain fixes and requests from the feedback from the last series.=
=20
And they should be applied after the last series.

A short summary of all patches the are following:
[PATCH 1/6] rt2x00 update: Remove casts from void* pointers
[PATCH 2/6] rt2x00 update: Deactivate monitor_during_oper for now
[PATCH 3/6] rt2x00 update: Use static const for the vals arrays
[PATCH 4/6] rt2x00 update: Remove packed attributes for structures that don=
't need it
[PATCH 5/6] rt2x00 update: Apply correct endian annotation for structures t=
hat are DMA'ed to device.
[PATCH 6/6] rt2x00 update: Apply correct error handling to dscape stack

Altough all patches are small and are inlined, I have added
them to the same location of the previous patch series.
http://mendiosus.nl/rt2x00/rt2x00-33-void-casts.diff
http://mendiosus.nl/rt2x00/rt2x00-34-monitor-operation.diff
http://mendiosus.nl/rt2x00/rt2x00-35-static-const.diff
http://mendiosus.nl/rt2x00/rt2x00-36-packed.diff
http://mendiosus.nl/rt2x00/rt2x00-37-endian-annotation.diff
http://mendiosus.nl/rt2x00/rt2x00-38-error-handling.diff

IvD

--nextPart2922498.NklX4tOok5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwoaqndE37Em0gRAg8nAJ9OsnsLOcLqE2DG8ddmN7yT3EQ27wCgrWdV
X3l9KaTtT5QbigsfdvSAADo=
=fehc
-----END PGP SIGNATURE-----

--nextPart2922498.NklX4tOok5--
