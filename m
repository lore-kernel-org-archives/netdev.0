From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 5/6] ARM: AM43xx: clk: Change the cpts ref clock source
 to dpll_core_m5 clk
Date: Mon, 28 Apr 2014 18:18:56 +0200
Message-ID: <20140428161856.GB4266@netboy>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
 <1398658225-25873-6-git-send-email-george.cherian@ti.com>
 <20140428071034.GB4380@netboy>
 <535E4FDC.70306@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com, ast@plumgrid.com,
	tklauser@distanz.ch, mpa@pengutronix.de, bhutchings@solarflare.com,
	zonque@gmail.com, balbi@ti.com, mugunthanvnm@ti.com,
	t-kristo@ti.com, mturquette@linaro.org, linux@arm.linux.org.uk,
	galak@codeaurora.org, ijc+devicetree@hellion.org.uk,
	mark.rutland@arm.com, pawel.moll@arm.com, robh+dt@kernel.org,
	tony@atomide.com, bcousson@baylibre.com
To: George Cherian <george.cherian@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <535E4FDC.70306@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 28, 2014 at 06:25:56PM +0530, George Cherian wrote:
> In beagle bone white (AM335x)  CPTS has a choice of 2 clocksource
> -dpll_core_m5_ck
> -dpll_core_m4_ck
> and by default  dpll_core_m5_ck is used. Where as in AM437x the
> default clocksource used is dpll_core_m4_ck .

Is your patch changing the default clock for am335x?

If yes, it shouldn't.
If no, then the patch description should say so.

Thanks,
Richard

 
