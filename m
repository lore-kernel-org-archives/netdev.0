From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] driver/e1000e: Fix default interrupt mode select
Date: Tue, 12 Apr 2011 14:27:27 -0700 (PDT)
Message-ID: <20110412.142727.39177723.davem@davemloft.net>
References: <1302584163-22318-1-git-send-email-prabhakar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, linux.nics@intel.com,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, meet2prabhu@gmail.com,
	b24347@freescale.com, jeffrey.t.kirsher@intel.com
To: prabhakar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932568Ab1DLV2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:28:03 -0400
In-Reply-To: <1302584163-22318-1-git-send-email-prabhakar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prabhakar Kushwaha <prabhakar@freescale.com>
Date: Tue, 12 Apr 2011 10:26:03 +0530

> From: Prabhakar <prabhakar@freescale.com>
> 
> The Intel e1000 device driver defaults to MSI interrupt mode, even if MSI
> support is not enabled
> 
> Signed-off-by: Jin Qing <b24347@freescale.com>
> Signed-off-by: Prabhakar Kushwaha <prabhakar@freescale.com>
> ---
>  Based upon git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git(branch master)
> 
>  added  netdev mail-list and e1000 mail-list & maintainer

Intel folks, you got this?
