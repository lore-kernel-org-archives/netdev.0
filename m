From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: Make phy_ethtool_ksettings_get return void
Date: Mon, 12 Jun 2017 10:25:25 -0400 (EDT)
Message-ID: <20170612.102525.1159274040679939960.davem@davemloft.net>
References: <20170612141508.29229-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, f.fainelli@gmail.com,
        siva.kallam@broadcom.com, prashant@broadcom.com,
        madalin.bucur@nxp.com, leoli@freescale.com,
        sebastian.hesselbarth@gmail.com,
        sergei.shtylyov@cogentembedded.com, grygorii.strashko@ti.com,
        w-kwok2@ti.com, m-karicheri2@ti.com, andrew@lunn.ch,
        woojung.huh@microchip.com, UNGLinuxDriver@microchip.com,
        vivien.didelot@savoirfairelinux.com, arnd@arndb.de,
        tremyfr@gmail.com, jarod@redhat.com, horms+renesas@verge.net.au,
        kazuya.mizuguchi.ks@renesas.com, dan.carpenter@oracle.com,
        niklas.soderlund+renesas@ragnatech.se, johan@kernel.org,
        masaru.nagai.vx@renesas.com, geert+renesas@glider.be,
        laurent.pinchart@ideasonboard.com, chris.brandt@renesas.com,
        ivan.khoronzhuk@linaro.org, mugunthanvnm@ti.com,
        netdev@vger.kernel.org, linux-arm-kernel
To: yuval.shaia@oracle.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170612141508.29229-1-yuval.shaia@oracle.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Mon, 12 Jun 2017 17:15:08 +0300

> Make return value void since function never return meaningfull value
> 
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
> v0 ->v1:
> 	* These files were missing in v0
> 		* drivers/net/ethernet/renesas/ravb_main.c
> 		* drivers/net/ethernet/renesas/sh_eth.c
> 		* drivers/net/ethernet/ti/netcp_ethss.c
> 	* Add Acked-by: Sergei Shtylyov
> v1 -> v2:
> 	* Adjust to net-next tree

Applied, thank you.
