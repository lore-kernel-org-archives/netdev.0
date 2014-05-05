From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] Add CPTS support for AM437x
Date: Mon, 05 May 2014 13:19:18 -0400 (EDT)
Message-ID: <20140505.131918.1426781180793240906.davem@davemloft.net>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org, richardcochran@gmail.com,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com, ast@plumgrid.com,
	tklauser@distanz.ch, mpa@pengutronix.de, bhutchings@solarflare.com,
	zonque@gmail.com, balbi@ti.com, mugunthanvnm@ti.com,
	t-kristo@ti.com, mturquette@linaro.org, linux@arm.linux.org.uk,
	galak@codeaurora.org, ijc+devicetree@hellion.org.uk,
	mark.rutland@arm.com, pawel.moll@arm.com, robh+dt@kernel.org,
	tony@atomide.com, bcousson@baylibre.com
To: george.cherian@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbaEERTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 13:19:25 -0400
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: George Cherian <george.cherian@ti.com>
Date: Fri, 2 May 2014 12:01:58 +0530

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
> v1 -> v2
> 	Patch 1 and 2 Re-ordering.
> 	Seperate TS_BITS define for Hw version V2 and V3

Series applied, thanks.
