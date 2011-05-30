From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 35992] Regression: oops when using a bridge interface
 with tg3
Date: Mon, 30 May 2011 04:58:11 +0200
Message-ID: <1306724291.6368.3.camel@edumazet-laptop>
References: <bug-35992-17701@https.bugzilla.kernel.org/>
	 <201105281013.p4SADfPS024949@demeter1.kernel.org>
	 <4DE0DDFE.9080308@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: Bernd Zeimetz <bzed@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35841 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab1E3C6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 22:58:16 -0400
Received: by wya21 with SMTP id 21so2344211wya.19
        for <netdev@vger.kernel.org>; Sun, 29 May 2011 19:58:15 -0700 (PDT)
In-Reply-To: <4DE0DDFE.9080308@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 28 mai 2011 =C3=A0 13:35 +0200, Bernd Zeimetz a =C3=A9crit :
> Hi,
>=20
> > OK, this sounds like an already fixed bug.
> >=20
> > (commit : 33eb9873a283a bridge: initialize fake_rtable metrics)
> >=20
> > Could you try latest linux-2.6 tree ?
>=20
> I've picked the commit into 2.6.39 and it fixed the issue, thanks for=
 the pointer.
>=20
>=20
> Could we please get that included in 2.6.39.1?
>=20

It will, David and Greg took care of this, thanks.



