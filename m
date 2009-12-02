From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/9] e1000e: enable new 82567V-3 device
Date: Wed, 02 Dec 2009 00:38:01 -0800 (PST)
Message-ID: <20091202.003801.93615243.davem@davemloft.net>
References: <20091202014931.519.25024.stgit@localhost.localdomain>
	<20091202015009.519.97730.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754700AbZLBIhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:37:55 -0500
In-Reply-To: <20091202015009.519.97730.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:50:31 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This new PCI device ID is for a new combination of MAC and PHY both of
> which already have supporting code in the driver, just not yet in this
> combination.  During validation of the device, an intermittent issue was
> discovered with waking it from a suspended state which can be resolved with
> the pre-existing workaround to disable gigabit speed prior to suspending.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
