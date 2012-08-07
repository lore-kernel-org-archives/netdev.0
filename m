From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Add device tree support for davinci_mdio driver
 and fix cpsw DT binding documentation
Date: Tue, 07 Aug 2012 16:25:20 -0700 (PDT)
Message-ID: <20120807.162520.1932972414873138617.davem@davemloft.net>
References: <1344265558-5724-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1344265558-5724-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 6 Aug 2012 20:35:56 +0530

> This patch set adds support for device tree for Davinci MDIO driver and fixes
> CPSW DT binding documentation to make it copy pastable to dts file.
> 
> This patch set is tested with the following git tree on AM335X Beagle Bone
> https://github.com/hvaibhav/am335x-linux/tree/am335x-upstream-staging-cpsw
> 
> Mugunthan V N (2):
>   drivers: net: ethernet: davince_mdio: device tree implementation
>   documentation: dt: bindings: cpsw: fixing the examples for directly
>     using it in dts file

Applied to net-next, thanks.
