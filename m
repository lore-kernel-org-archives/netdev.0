From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] e1000: update netstats traffic counters realtime
Date: Tue, 13 Nov 2007 20:51:23 -0800 (PST)
Message-ID: <20071113.205123.230227348.davem@davemloft.net>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
	<20071113231117.13177.49045.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757474AbXKNEvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:51:23 -0500
In-Reply-To: <20071113231117.13177.49045.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 13 Nov 2007 15:11:17 -0800

> formerly e1000/e1000e only updated traffic counters once every
> 2 seconds with the register values of bytes/packets. With newer
> code however in the interrupt and polling code we can real-time
> fill in these values in the netstats struct for users to see.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Applied to netdev-2.6, thanks.
