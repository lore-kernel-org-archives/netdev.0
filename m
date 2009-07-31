From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: Fix netpoll to be properly
 multiqueue aware
Date: Thu, 30 Jul 2009 19:28:57 -0700 (PDT)
Message-ID: <20090730.192857.148595537.davem@davemloft.net>
References: <20090730222501.26121.2952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751342AbZGaC2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 22:28:49 -0400
In-Reply-To: <20090730222501.26121.2952.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Jul 2009 15:25:09 -0700

> Our ndo_poll_controller callback is broken for anything but non-multiqueue
> setups.  This fixes that issue.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
