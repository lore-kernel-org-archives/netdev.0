From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 15/15] ARM: dts: am335x/am437x/dra7: use new
 "ti,cpsw-mdio" compat string
Date: Tue, 21 Jun 2016 04:34:22 -0700
Message-ID: <20160621113422.GQ22406@atomide.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-16-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160615115603.4897-16-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Grygorii Strashko <grygorii.strashko@ti.com> [160615 05:05]:
> Add "ti,cpsw-mdio" for am335x/am437x/dra7 SoCs where MDIO is
> implemented as part of TI CPSW and, this way, enable PM runtime auto
> suspend for Davinci MDIO driver on these paltforms.

This one should not cause merge conflicts, please feel free
to merge along with the other CPSW driver patches after the
pending comments are dealt with:

Acked-by: Tony Lindgren <tony@atomide.com>
