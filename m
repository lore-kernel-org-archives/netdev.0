From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ethtool: Fix filter addition when
 caching n-tuple filters
Date: Mon, 15 Feb 2010 21:52:46 -0800 (PST)
Message-ID: <20100215.215246.226455808.davem@davemloft.net>
References: <20100212234715.2346.60380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807Ab0BPFwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:52:31 -0500
In-Reply-To: <20100212234715.2346.60380.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Feb 2010 15:48:05 -0800

> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> We can allow a filter to be added successfully to the underlying
> hardware, but still return an error if the cached list memory
> allocation fails.  This patch fixes that condition.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
