From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 11:27:29 -0700 (PDT)
Message-ID: <20130621.112729.1807883476742785070.davem@davemloft.net>
References: <1371810775.19215.30.camel@joe-AO722>
	<4881796E12491D4BB15146FE0209CE643F5F587E@DE02WEMBXB.internal.synopsys.com>
	<1371825813.19215.34.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey.Brodkin@synopsys.com, netdev@vger.kernel.org,
	andy.shevchenko@gmail.com, romieu@fr.zoreil.com,
	Vineet.Gupta1@synopsys.com, Mischa.Jonker@synopsys.com,
	arnd@arndb.de, grant.likely@linaro.org, rob.herring@calxeda.com,
	paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, florian@openwrt.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371825813.19215.34.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 21 Jun 2013 07:43:33 -0700

> Maybe add a Kconfig "depends on !64BIT".

Please, no.
