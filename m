From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 19/23] ptp: tilegx: convert to the 64 bit
 get/set time methods.
Date: Mon, 23 Mar 2015 21:06:26 +0100
Message-ID: <20150323200625.GA7120@netboy>
References: <cover.1426973658.git.richardcochran@gmail.com>
 <8bc233b19d08308c01015936841d9be8d4441ece.1426973658.git.richardcochran@gmail.com>
 <551038FB.2070200@ezchip.com>
 <20150323165839.GA4330@localhost.localdomain>
 <55104CBE.90603@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.c
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37078 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbbCWUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:06:33 -0400
Content-Disposition: inline
In-Reply-To: <55104CBE.90603@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 01:26:22PM -0400, Chris Metcalf wrote:
> As far as I know, the tilegx driver is the only client of those gxio
> routines.

...

> I guess that brings us back to changing the gxio_xxx APIs.

Ok, I'll do that for the next round.

Thanks,
Richard
