From: Jakub Narebski <jnareb@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 22:55:24 +0200
Message-ID: <fu5p3i$96n$1@ger.gmane.org>
References: <48028830.6020703@earthlink.net> <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu> <20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org> <20080414072328.GW9785@ZenIV.linux.org.uk> <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au> <4804765B.2070300@davidnewall.com> <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com> <20080416132634.GA545@cs181133002.pp.htv.fi> <20080416200408.GA7764@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: git@vger.kernel.org
Return-path: <git-owner@vger.kernel.org>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau wrote:

> Note to contributors: it's very handy when patches comes with a prope=
rly
> formated subject. Try to put one of the following words between brack=
ets
> to indicate the importance of the patch followed by a short descripti=
on:
>=20
> [MINOR] =A0 =A0minor fix, very low risk of impact
> [MEDIUM] =A0 medium risk, may cause unexpected regressions of low imp=
ortance or
> =A0 =A0 =A0 =A0 =A0 =A0which may quickly be discovered

[...]

And git-am strips such prefixes because of [PATCH] and [PATCH n/m] whic=
h
should be stripped.

--=20
Jakub Narebski
Warsaw, Poland
ShadeHawk on #git
