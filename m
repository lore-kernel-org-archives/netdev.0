From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/5] igb: fix PHY config access on 82580
Date: Thu, 01 Jul 2010 22:49:58 -0700 (PDT)
Message-ID: <20100701.224958.32717002.davem@davemloft.net>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49317
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754740Ab0GBFto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:49:44 -0400
In-Reply-To: <20100701233733.16171.4629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:37:54 -0700

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> 82580 NICs can have up to 4 functions. This fixes phy accesses
> to use the correct locks for functions 2 and 3.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
