From: Scott Wood <oss@buserror.net>
Subject: Re: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Thu, 07 Jul 2016 15:42:54 -0500
Message-ID: <1467924174.32358.69.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <1465609853.22191.151.camel@buserror.net>
	 <HE1PR04MB0889646206BFAD68046F3473F83B0@HE1PR04MB0889.eurprd04.prod.outlook.com>
	 <4094106.qfxJu3tJbO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Ulf Hansson <ulf.hansson@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	Xiaob
To: Arnd Bergmann <arnd@arndb.de>, Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <4094106.qfxJu3tJbO@wuerfel>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-07-07 at 10:30 +0200, Arnd Bergmann wrote:
> On Thursday, July 7, 2016 2:35:33 AM CEST Yangbo Lu wrote:
> >=20
> > Hi Arnd,
> >=20
> > Could you reply when you see the email?
> > If your method doesn=E2=80=99t resolve the problem, we still want t=
o use our old
> > patchset.
> >=20
> > This guts driver had been discussed about one year and blocked many
> > workaround upstream.
> > So please help to review and comment soon.
> >=20
> I don't really see how more discussion is going to help us here. I th=
ink
> I've made it pretty clear that I don't want to see another platform
> specific way to read an SoC revision and I've even sent a proof-of-co=
ncept
> patch to show how the interface can work, now it's up to you to fit t=
he
> guts hardware into that and send a new patch series.

In which relevant maintainership capacity are you NACKing it?

-Scott
