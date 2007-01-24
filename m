From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: dscape doesn't auto associate
Date: Tue, 23 Jan 2007 23:26:41 -0500
Message-ID: <200701232326.46522.flamingice@sourmilk.net>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com> <200701231843.05902.flamingice@sourmilk.net> <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1917332.8Y51Rq3ttx";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>
To: "Jon Smirl" <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:13597 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965488AbXAXE1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 23:27:14 -0500
In-Reply-To: <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1917332.8Y51Rq3ttx
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 23 January 2007 20:48, Jon Smirl wrote:
> I'll try running NetworkManager in the debugger and see if I can
> figure out what is failing. NetworkManager is working ok for me on
> non-dscape devices.
>
Dan, any idea what's happening?

=46WIW, I'm running NetworkManager 0.6.2 (from SuSE 10.1) with wpa_supplica=
nt=20
0.5.7.

> zd1211 has this problem too:
> Error for wireless request "Set Encode" (8B2A) :
>     SET failed on device wlan1 ; Invalid argument.
>
Shouldn't happen if it works for rt2570. Both use software encryption.

=2DMichael Wu

--nextPart1917332.8Y51Rq3ttx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFtuAGT3Oqt9AH4aERAu5YAJ0ameew8y8NDUthGb5lrTqM05gEiACcCoxw
c9MJpEo5UoWdhY3es4rQmm8=
=F4+X
-----END PGP SIGNATURE-----

--nextPart1917332.8Y51Rq3ttx--
