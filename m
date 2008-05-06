From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 19:33:46 -0700
Message-ID: <481FC38A.6070805@redhat.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com> <20080505185850.789d870a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbYEFCeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 22:34:01 -0400
In-Reply-To: <20080505185850.789d870a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> afaict we only ever remap one or two flags.

So far.  I have plans for at least one more flag: the one we'll
hopefully have sometime soon to request non-sequential file descriptors=
=2E
 There is no reason why there shouldn't be even more in future.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIH8OK2ijCOnn/RHQRAgd/AJ47rSUE8UZotXuce4mp6SMWn08OQACdH8tS
kcd8c40jXlDlE1LySSdf5mQ=3D
=3D7KVe
-----END PGP SIGNATURE-----
