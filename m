From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] ixgbe: Create separate media type for CX4
 adapters
Date: Mon, 14 Sep 2009 17:08:42 -0700 (PDT)
Message-ID: <20090914.170842.170754678.davem@davemloft.net>
References: <20090914174659.4560.28814.stgit@localhost.localdomain>
	<20090914174809.4560.72843.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933602AbZIOAI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:08:26 -0400
In-Reply-To: <20090914174809.4560.72843.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 14 Sep 2009 10:48:10 -0700

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> Currently the media type detection for CX4 adapters lumps them into a
> type of fiber.  This causes some strange fallout when firmware verification
> is done on the NIC, and certain fiber NIC rules get enforced incorrectly.
> 
> This patch introduces a new media type for CX4, and puts both 82598 and
> 82599 CX4 adapters into this bucket.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>

Applied.
