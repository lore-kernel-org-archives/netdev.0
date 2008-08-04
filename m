From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [patch 4/4] Configure out IGMP support
Date: Mon, 4 Aug 2008 15:53:38 +0300
Message-ID: <20080804125338.GG6088@cs181140183.pp.htv.fi>
References: <20080731092703.661994657@free-electrons.com> <20080731093221.565015353@free-electrons.com> <1217619715.3454.488.camel@pmac.infradead.org> <20080804144807.6b2374d9@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Woodhouse <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080804144807.6b2374d9@surf>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2008 at 02:48:07PM +0200, Thomas Petazzoni wrote:
> Le Fri, 01 Aug 2008 20:41:55 +0100,
> David Woodhouse <dwmw2@infradead.org> a =C3=A9crit :
>=20
> > The config option probably lives in net/Kconfig, not init/Kconfig.
>=20
> Yes, it could. But AFAIK, until now, all CONFIG_EMBEDDED-related
> options have been put in init/Kconfig.
>...

No, the vast majority is actually outside of init/Kconfig.

> Sincerly,
>=20
> Thomas

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
