From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: Refactor set_num_queues() and
 cache_ring_register()
Date: Thu, 05 Feb 2009 23:54:52 -0800 (PST)
Message-ID: <20090205.235452.245713179.davem@davemloft.net>
References: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbZBFHy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:54:56 -0500
In-Reply-To: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 04 Feb 2009 17:39:02 -0800

> The current code to determine the number of queues the device will want
> on driver initialization is ugly and difficult to maintain.  It also
> doesn't allow for easy expansion for future features or future hardware.
> This patch refactors these routines, and make them easier to deal with.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
