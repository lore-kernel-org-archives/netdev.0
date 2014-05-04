From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/6] Add CPTS support for AM437x
Date: Sun, 4 May 2014 18:24:22 +0200
Message-ID: <20140504162422.GA28908@netboy>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
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
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 02, 2014 at 12:01:58PM +0530, George Cherian wrote:
> The series adds CPTS support for AM4372.
> 
> Patch 1 - DT changes w.r.t clock changes for AM33xx.
> Patch 2 - CPTS clock name harcoding in the driver is removed. 
> 	  Easier to pass the clock name from dt rather than hardcoding in driver.
> 	  Also in prepration for DRA7x CPTS support.
> Patch 3 - Enable the CPTS support for both DRA7x and AM4372 in the driver.
> Patch 4 - Enable the Annexe F for L2 PTP for AM437x and DRA7x.
> Patch 5 - Change the default clocksource to dpll_core_m5 
> Patch 6 - DT changes for AM4372.
> 
> 
> v1 -> v2
> 	Patch 1 and 2 Re-ordering.
> 	Seperate TS_BITS define for Hw version V2 and V3

Acked-by: Richard Cochran <richardcochran@gmail.com>
