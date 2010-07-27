From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: priority tagging FCoE frames
 without FCoE offload
Date: Tue, 27 Jul 2010 13:18:30 -0700 (PDT)
Message-ID: <20100727.131830.214211224.davem@davemloft.net>
References: <20100727064058.24599.57844.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com, john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53903
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750816Ab0G0USN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 16:18:13 -0400
In-Reply-To: <20100727064058.24599.57844.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Jul 2010 23:41:31 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> The DCB user priority for FCoE is available regardless of whether
> FCoE offload is enabled (IXGBE_FLAG_FCOE_ENABLED bit is set).
> This allows proper DCB user priority tagging for FCoE
> traffic on both 82598 and 82599 devices.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
