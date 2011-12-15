From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: pull request: wireless 2011-12-15
Date: Thu, 15 Dec 2011 21:04:29 +0100
Message-ID: <CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
References: <20111215191523.GA2561@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111215191523.GA2561@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/15 John W. Linville <linville@tuxdriver.com>:
> commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e
>
> Dave,
>
> Here are a few more fixes intended for the 3.2 release. =C2=A0They ar=
e
> all small and narrowly focused.

John, I've made a mistake and didn't use [PATCH 3.2] header to make it
clean my patch is fix. Could you take a look at
[PATCH] bcma: support for suspend and resume
please?

It's not one-liner, but fixes lock ups, which I believe - we really
want to avoid.

--=20
Rafa=C5=82
