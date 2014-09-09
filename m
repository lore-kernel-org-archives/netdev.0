From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Tue, 9 Sep 2014 14:27:34 -0400
Message-ID: <20140909182734.GJ29412@tuxdriver.com>
References: <20140213201421.GJ22203@tuxdriver.com>
 <1397581703.8212.5.camel@x220>
 <CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
 <1403087119.1984.93.camel@x220>
 <CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
 <1403091974.1984.102.camel@x220>
 <1409911856.7832.9.camel@x220>
 <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>
 <1409916824.7832.20.camel@x220>
 <CAHNKnsQ1gt=DRBTd9Q9yos1idqmXMepEPvhm8a7unP-whzNAgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Bolle <pebolle@tiscali.nl>, Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	ath5k-devel@venema.h4ckr.net, open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <list@hauke-m.de>,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHNKnsQ1gt=DRBTd9Q9yos1idqmXMepEPvhm8a7unP-whzNAgg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 05, 2014 at 04:02:10PM +0400, Sergey Ryazanov wrote:
> 2014-09-05 15:33 GMT+04:00 Paul Bolle <pebolle@tiscali.nl>:
> > Hi Sergey,
> >
> > On Fri, 2014-09-05 at 15:12 +0400, Sergey Ryazanov wrote:
> >> 2014-09-05 14:10 GMT+04:00, Paul Bolle <pebolle@tiscali.nl>:
> >> > On Wed, 2014-06-18 at 13:46 +0200, Paul Bolle wrote:
> >> >> Having this conversation every rc1 is getting a bit silly. Could Jiri
> >> >> e.a. perhaps set some specific deadline for ATHEROS_AR231X to be
> >> >> submitted?
> >> >
> >> > I waited until rc3. Have you seen any activity on this front? If not,
> >> > should I resend the patch that removes the code in mainline that depends
> >> > on ATHEROS_AR231X (ie, AHB bus support)?
> >> >
> >> Recent activity always could be found in [1]. Now I finish another one
> >> round of cleanups and have a plan to fix several things (you can
> >> always find something that you really want to improve). But if you
> >> insist I could immediately switch to "send upstream" mode. And seems
> >> that this would be better approach.
> >>
> >> 1. https://dev.openwrt.org/log/trunk/target/linux/atheros
> >
> > And where can the related PULL requests or patch submissions be found?
> >
> I have not sent patches yet, since I thought that it would be easier
> to cleanup them in openwrt tree and then send them upstream.

That excuse has worn a bit thin.  Perhaps Paul should repost his
removal and you can add a revert to the start of your patch series?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
