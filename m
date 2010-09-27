From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] Gigabit Ethernet driver of Topcliff PCH
Date: Mon, 27 Sep 2010 08:10:00 +0200
Message-ID: <1285567800.2357.565.camel@edumazet-laptop>
References: <4CA03198.8080802@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	MeeGo <meego-dev@meego.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA03198.8080802@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 27 septembre 2010 =C3=A0 14:54 +0900, Masayuki Ohtake a =C3=A9=
crit :
> Gigabit Ethernet driver of Topcliff PCH
>=20
> Topcliff PCH is the platform controller hub that is going to be used =
in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus.=20
> Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to=20
> access system devices connected to Gigabit Ethernet.
>=20
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> ---

Hmm, what is going on ?

David already put your driver in net-next-2.6

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3D77555ee7228234257957fd54daa0b69178906320

If you want to make changes, you have to send diffs now, not the full
version.

Thanks
