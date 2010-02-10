From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: fec fixes
Date: Wed, 10 Feb 2010 13:06:10 -0800 (PST)
Message-ID: <20100210.130610.132690227.davem@davemloft.net>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, gerg@uclinux.org,
	u.kleine-koenig@pengutronix.de, amit.kucheria@verdurent.com
To: amit.kucheria@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265396105.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amit Kucheria <amit.kucheria@canonical.com>
Date: Fri,  5 Feb 2010 10:56:19 -0800

> Some fixes to the fec driver to get it to work on the Freescale i.MX5 SoC
> platform
> 
> Amit Kucheria (2):
>   fec: Add LAN8700 phy support
>   fec: Add ARCH_MX5 as a dependency
> 
> Rob Herring (1):
>   fec: fix uninitialized rx buffer usage

All applied to net-next-2.6, thanks.
