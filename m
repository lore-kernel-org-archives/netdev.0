From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgb: Use pr_<level> and netdev_<level>
Date: Tue, 27 Apr 2010 12:55:38 -0700 (PDT)
Message-ID: <20100427.125538.173862065.davem@davemloft.net>
References: <20100427104952.23637.6317.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756777Ab0D0Tzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:55:32 -0400
In-Reply-To: <20100427104952.23637.6317.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 03:50:58 -0700

> From: Joe Perches <joe@perches.com>
> 
> Convert DEBUGOUTx to pr_debug
> Convert DEBUGFUNC to more commonly used ENTER
> Convert mac address output to %pM
> Use #define pr_fmt
> Convert a few printks to pr_<level>
> Improve ixgb_mc_addr_list_update: use a temporary for current mc address
> Use etherdevice.h functions for mac address testing
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
