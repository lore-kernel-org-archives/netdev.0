From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] ixgbe: Remove legacy descriptor
 support
Date: Fri, 17 Jul 2009 09:47:50 -0700 (PDT)
Message-ID: <20090717.094750.257194361.davem@davemloft.net>
References: <20090717014951.24074.75893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933619AbZGQQrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 12:47:46 -0400
In-Reply-To: <20090717014951.24074.75893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Jul 2009 18:50:12 -0700

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> The ethtool offline test is the only consumer of the legacy descriptors.
> Update that path to only use advanced descriptors, and remove all support
> for legacy descriptors.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
