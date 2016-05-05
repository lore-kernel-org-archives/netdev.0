From: Rob Herring <robh@kernel.org>
Subject: Re: [v10, 1/7] Documentation: DT: update Freescale DCFG compatible
Date: Thu, 5 May 2016 17:25:21 -0500
Message-ID: <20160505222521.GA18377@rob-hp-laptop>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
 <1462417950-46796-2-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mmc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-clk@vger.kernel.org,
	linux-i2c@vger.kernel.org, iommu@lists.linux-foundation.org,
	netdev@vger.kernel.org, ulf.hansson@linaro.org,
	Scott Wood <oss@buserror.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-i2c-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462417950-46796-2-git-send-email-yangbo.lu@nxp.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2016 at 11:12:24AM +0800, Yangbo Lu wrote:
> Update Freescale DCFG compatible with 'fsl,<chip>-dcfg' instead
> of 'fsl,ls1021a-dcfg' to include more chips such as ls1021a,
> ls1043a, and ls2080a.
> 
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> ---
> Changes for v8:
> 	- Added this patch
> Changes for v9:
> 	- Added a list for the possible compatibles
> Changes for v10:
> 	- None
> ---
>  Documentation/devicetree/bindings/arm/fsl.txt | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
