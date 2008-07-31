From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 18:35:46 +0200
Message-ID: <20080731183546.2b047cee@surf>
References: <1217500967.3454.140.camel@pmac.infradead.org>
	<20080731.035121.177567346.davem@davemloft.net>
	<1217503770.3454.162.camel@pmac.infradead.org>
	<20080731.043355.143045459.davem@davemloft.net>
	<1217504801.3454.170.camel@pmac.infradead.org>
	<20080731155820.GC20212@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, mpm@selenic.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20080731155820.GC20212@cs181140183.pp.htv.fi>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Thu, 31 Jul 2008 18:58:20 +0300,
Adrian Bunk <bunk@kernel.org> a =C3=A9crit :

> It might have also made more sense to spend some of the energy used
> in this discussion instead on checking where the global 24 kB size
> increase Thomas reported for 2.6.27-rc1 compared to 2.6.26 comes from=
=2E

I agree. This is something I'm working on. I hope to have results soon.
But I *fear* that the results will be: the size growth is 10 bytes
here, 22 bytes there, 35 bytes here, spread over hundreds of patches.
Something we can do anything against.

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
