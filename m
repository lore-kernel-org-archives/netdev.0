From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] ks8851 DT/regulator/gpio updates
Date: Sat, 24 May 2014 14:03:58 -0400 (EDT)
Message-ID: <20140524.140358.1963098926345179335.davem@davemloft.net>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	nm@ti.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, devicetree@vger.kernel.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Fri, 23 May 2014 12:57:16 -0700

> This set of patches properly documents the micrel ks8851 spi ethernet
> controller, converts to devm_regulator_get_optional() to make error
> paths slightly simpler, and finally adds supports for another
> optional regulator and a reset gpio. This allows me to use the ks8851
> on my MSM8960 CDP board.
> 
> Changes since v1:
>  * Dropped vendor prefix patch as that should go through DT tree

Series applied, thanks Stephen!
