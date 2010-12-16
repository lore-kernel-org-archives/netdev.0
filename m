From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip: Few typo and grammar errors fixes for ip(8) manpage
Date: Thu, 16 Dec 2010 17:58:25 +0100
Message-ID: <1292518705.2883.400.camel@edumazet-laptop>
References: <1292516694-9156-1-git-send-email-psabata@redhat.com>
	 <1292517178.2883.364.camel@edumazet-laptop>
	 <1292518217.3253.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Petr Sabata <psabata@redhat.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39433 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab0LPQ6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 11:58:31 -0500
Received: by fxm18 with SMTP id 18so3487696fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 08:58:30 -0800 (PST)
In-Reply-To: <1292518217.3253.3.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 16:50 +0000, Ben Hutchings a =C3=A9=
crit :
> On Thu, 2010-12-16 at 17:32 +0100, Eric Dumazet wrote:
> > Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 17:24 +0100, Petr Sabata a =C3=
=A9crit :
> > > ---
> > >  man/man8/ip.8 |    6 +++---
> > >  1 files changed, 3 insertions(+), 3 deletions(-)
> > >=20
> >=20
> > MAN-PAGES: MANUAL PAGES FOR LINUX -- Sections 2, 3, 4, 5, and 7
> > M:      Michael Kerrisk <mtk.manpages@gmail.com>
> > W:      http://www.kernel.org/doc/man-pages
> > L:      linux-man@vger.kernel.org
> > S:      Maintained
>=20
> What is your point?  This is a patch for iproute2, so it should go to
> Stephen Hemminger.

Hmm, thats right, I misread patch, sorry.

Patches for iproute2 should be labeled as such, and sent to maintainer,
to avoid confusion.



