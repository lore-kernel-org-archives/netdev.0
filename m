From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2011-12-15
Date: Thu, 15 Dec 2011 16:38:22 -0500
Message-ID: <20111215213822.GB2561@tuxdriver.com>
References: <20111215191523.GA2561@tuxdriver.com>
 <CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2011 at 09:04:29PM +0100, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> 2011/12/15 John W. Linville <linville@tuxdriver.com>:
> > commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e
> >
> > Dave,
> >
> > Here are a few more fixes intended for the 3.2 release. =C2=A0They =
are
> > all small and narrowly focused.
>=20
> John, I've made a mistake and didn't use [PATCH 3.2] header to make i=
t
> clean my patch is fix. Could you take a look at
> [PATCH] bcma: support for suspend and resume
> please?
>=20
> It's not one-liner, but fixes lock ups, which I believe - we really
> want to avoid.

It's late in the release cycle, and Dave specifically asked me to slow =
down.

Are these suspend/resume lockups a regression?  Or have they always
been there?  Do they happen to everyone?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
