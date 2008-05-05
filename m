From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 01/18] flag parameters: helper function
Date: Sun, 04 May 2008 22:02:38 -0700
Message-ID: <481E94EE.2060800@redhat.com>
References: <200805050342.m453gkY4029814@devserv.devel.redhat.com> <Pine.LNX.4.64.0805042144320.8307@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbYEEFFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 01:05:32 -0400
In-Reply-To: <Pine.LNX.4.64.0805042144320.8307@alien.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Davide Libenzi wrote:
> I dunno if this deserves separate c/h files. Otherwise ...

I used separate files because all of the users are in optional code.  I
would have had to stuff the code in a completely unrelated file which I
think isn't clean.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkgelO4ACgkQ2ijCOnn/RHSVQgCffwvlbMeZTI5N19+J13VS8+ng
8/0AoI8wwTtrAwbFIbuu9e4RrvEIzWGC
=3D2gim
-----END PGP SIGNATURE-----
