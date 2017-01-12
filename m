From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 2/2] ARM: dts: dra72-evm-revc: enable irqs for dp83867
 eth phys
Date: Thu, 12 Jan 2017 14:27:22 -0800
Message-ID: <20170112222722.GN2630@atomide.com>
References: <20170106205543.4748-1-grygorii.strashko@ti.com>
 <20170106215451.GI2630@atomide.com>
 <cd8cdb56-ca47-6e17-43b4-daedc7889612@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:56942 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751009AbdALW1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 17:27:25 -0500
Content-Disposition: inline
In-Reply-To: <cd8cdb56-ca47-6e17-43b4-daedc7889612@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Grygorii Strashko <grygorii.strashko@ti.com> [170109 11:26]:
> 
> 
> On 01/06/2017 03:54 PM, Tony Lindgren wrote:
> > * Grygorii Strashko <grygorii.strashko@ti.com> [170106 12:56]:
> > > TI DRA72-EVM Rev C has two DP83867 ethernet phys which support IRQ
> > > generation in case of phy/link status changes. The INT/PWDN lines from both
> > > DP83867 phys are wired to DRA7 gpio6.16, so reflect the same in DT.
> > 
> > Hmm not seeing the patch 1/2 here.. Can this one be queued separately?
> > Is it for v4.11 or a fix?
> 
> This is for next (v4.11) and there is just a mistake in subj, Sry.

OK applying into omap-for-v4.11/dt thanks.

Tony
