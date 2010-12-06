From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 2/2] bluetooth: Use printf extension %pMbt
Date: Mon, 6 Dec 2010 18:07:51 -0200
Message-ID: <20101206200751.GF883@vigoh>
References: <cover.1291419007.git.joe@perches.com>
 <b966e9510dec12556a3d1313b026cb2c8281e4d6.1291419007.git.joe@perches.com>
 <20101206181507.GC883@vigoh>
 <1291661413.17494.219.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291661413.17494.219.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

* Joe Perches <joe@perches.com> [2010-12-06 10:50:13 -0800]:

> On Mon, 2010-12-06 at 16:15 -0200, Gustavo F. Padovan wrote:
> > This patch doesn't apply to the bluetooth-next-2.6 tree.
> > Can you please rebase it against the bluetooth-next-2.6 tree?
>=20
> No worries, it was done against next-20101202.
>=20
> Do you care about using %pMR vs %pMbt as Micha=C5=82 suggested in
> https://lkml.org/lkml/2010/12/4/21 ?

I'm fine either way. It depends more if another subsystem will want to =
use
%pMR or not as you said.

--=20
Gustavo F. Padovan
http://profusion.mobi
