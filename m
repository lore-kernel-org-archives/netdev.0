From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: convert drivers/net/ethernet/* to use
 module_platform_driver()
Date: Tue, 29 Nov 2011 01:17:17 -0500 (EST)
Message-ID: <20111129.011717.1510779658553334799.davem@davemloft.net>
References: <1322448257.2408.6.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, mcuos.com@gmail.com, nico@fluxnic.net,
	peppe.cavallaro@st.com, mkl@pengutronix.de,
	jeffrey.t.kirsher@intel.com, jpirko@redhat.com, daniel@gaisler.com,
	adobriyan@gmail.com, tklauser@distanz.ch,
	grant.likely@secretlab.ca, jkosina@suse.cz,
	richard.cochran@omicron.at, jonas@southpole.se,
	sebastian.poehn@belden.com, yoshihiro.shimoda.uh@renesas.com,
	ricardo.ribalda@gmail.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322448257.2408.6.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Mon, 28 Nov 2011 10:44:17 +0800

> This patch converts the drivers in drivers/net/ethernet/* to use the
> module_platform_driver() macro which makes the code smaller and a bit
> simpler.
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Applied.
