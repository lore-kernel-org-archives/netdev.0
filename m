From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [v7, 4/5] powerpc/fsl: move mpc85xx.h to include/linux/fsl
Date: Tue, 5 Apr 2016 12:35:26 +0200
Message-ID: <20160405103526.GG17838@8bytes.org>
References: <1459480051-3701-1-git-send-email-yangbo.lu@nxp.com>
 <1459480051-3701-5-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-clk@vger.kernel.org, linux-i2c@vger.kernel.org,
	iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	scott.wood@nxp.com, Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	ulf.hansson@linaro.org,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Zhao Qiang <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-i2c-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459480051-3701-5-git-send-email-yangbo.lu@nxp.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2016 at 11:07:30AM +0800, Yangbo Lu wrote:
> Move mpc85xx.h to include/linux/fsl and rename it to svr.h as
> a common header file. It has been used for mpc85xx and it will
> be used for ARM-based SoC as well.
> 
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> Acked-by: Wolfram Sang <wsa@the-dreams.de>

Acked-by: Joerg Roedel <jroedel@suse.de>
