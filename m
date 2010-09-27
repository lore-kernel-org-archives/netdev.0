From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH v6] Gigabit Ethernet driver of Topcliff PCH
Date: Mon, 27 Sep 2010 15:39:57 +0900
Message-ID: <002c01cb5e0e$d23087a0$66f8800a@maildom.okisemi.com>
References: <4CA03198.8080802@dsn.okisemi.com> <1285567800.2357.565.camel@edumazet-laptop>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Randy Dunlap" <randy.dunlap@oracle.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"Maxime Bizon" <mbizon@freebox.fr>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"ML netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"MeeGo" <meego-dev@meego.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric

Thank you for information.
I did not know "net-next-2.6."
This driver is not changed.

Thanks, Ohtake
-----
Date: Mon, 27 Sep 2010 08:10:00 +0200
From: "Eric Dumazet" <eric.dumazet@gmail.com>


> Le lundi 27 septembre 2010 a 14:54 +0900, Masayuki Ohtake a ecrit :
> > Gigabit Ethernet driver of Topcliff PCH
> >
> > Topcliff PCH is the platform controller hub that is going to be used in
> > Intel's upcoming general embedded platform. All IO peripherals in
> > Topcliff PCH are actually devices sitting on AMBA bus.
> > Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to
> > access system devices connected to Gigabit Ethernet.
> >
> > Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> > ---
>
> Hmm, what is going on ?
>
> David already put your driver in net-next-2.6
>
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=77555ee7228234257957fd54daa0b69178906320
>
> If you want to make changes, you have to send diffs now, not the full
> version.
