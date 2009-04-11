From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] ixgbe: Enable another bit for flow control
 operation
Date: Sat, 11 Apr 2009 02:49:55 -0700 (PDT)
Message-ID: <20090411.024955.102977935.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757009AbZDKJuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:50:04 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:26:21 -0700

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> The discard pause frames bit was not enabled, so flow control frames could
> be passed up to the host.  Enabled DPF to keep the frames off the stack.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
