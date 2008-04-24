From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Thu, 24 Apr 2008 14:35:46 -0700
Message-ID: <4810FD32.3070701@redhat.com>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com> <20080424215858.771f718a@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753350AbYDXVgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 17:36:32 -0400
In-Reply-To: <20080424215858.771f718a@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:
> Can we also get
> the behaviour of flag inheritance and other stuff defined in any futu=
re
> API spec for this so it is consistent across platforms too - that wil=
l
> also let the new accept be used in the longer term to make portable c=
ode
> easier.

If you write it down I'll bring it forward and on the agenda for
standardization in the 201x revision.  We are not adding new
functionality in corrigendas.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIEP0y2ijCOnn/RHQRAh5kAJ9GRZQCfxTL9mgi/UGxzowvdyLGbQCdEvHE
TmZcS+rOZcxMwpIltQYA6bI=3D
=3DIKA3
-----END PGP SIGNATURE-----
