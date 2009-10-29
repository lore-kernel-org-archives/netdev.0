From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] net: Add ndo_fcoe_get_wwn to
 net_device_ops
Date: Thu, 29 Oct 2009 01:04:44 -0700 (PDT)
Message-ID: <20091029.010444.187410674.davem@davemloft.net>
References: <20091029042339.15957.37676.stgit@localhost.localdomain>
	<20091029042434.15957.82934.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751862AbZJ2IEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:04:20 -0400
In-Reply-To: <20091029042434.15957.82934.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 28 Oct 2009 21:24:35 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Add ndo_fcoe_get_wwn so Fiber Channel over Ethernet (FCoE) can make use of
> the provided World Wide Port Name (WWPN) and World Wide Node Name (WWNN)
> from the underlying network interface driver.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
