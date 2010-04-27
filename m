From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: Fix link speed display
Date: Tue, 27 Apr 2010 14:36:19 -0700 (PDT)
Message-ID: <20100427.143619.209975415.davem@davemloft.net>
References: <20100427213143.25913.83381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36833
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757232Ab0D0VgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:36:13 -0400
In-Reply-To: <20100427213143.25913.83381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 14:31:45 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The ixgbevf driver would always report 10Gig speeds even when the link
> speed is downshifted to 1Gig.  This patch fixes that problem.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
