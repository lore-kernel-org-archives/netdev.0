From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 1/1] OMAP: wlan: Set the WLAN Regulator to be
 always on
Date: Tue, 16 Aug 2011 09:07:03 -0700
Message-ID: <20110816160703.GA19544@kroah.com>
References: <1313507037-2467-1-git-send-email-panduranga_mallireddy@ti.com>
 <1313507037-2467-2-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, ohad@wizery.com, pradeepgurumath@ti.com,
	coelho@ti.com, netdev@vger.kernel.org, naveen_jain@ti.com,
	x-boudet@ti.com, vishalm@ti.com, manjunatha_halli@ti.com,
	benzyg@ti.com, linux-omap@vger.kernel.org
To: panduranga_mallireddy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:53598 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751562Ab1HPQHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 12:07:37 -0400
Content-Disposition: inline
In-Reply-To: <1313507037-2467-2-git-send-email-panduranga_mallireddy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2011 at 10:03:57AM -0500, panduranga_mallireddy@ti.com wrote:
> From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
> 
> For regulator omap4_clk32k used by wlan, set .constraints.always_on to 1.
> This regulator should never be disabled.
> 
> Signed-off-by: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
> ---
>  arch/arm/mach-omap2/twl-common.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
