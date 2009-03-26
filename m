From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] e1000: fix tx hang detect logic and
 address dma mapping issues
Date: Thu, 26 Mar 2009 01:01:53 -0700 (PDT)
Message-ID: <20090326.010153.170024359.davem@davemloft.net>
References: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755382AbZCZICH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:02:07 -0400
In-Reply-To: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 00:58:45 -0700

> This patch changes the dma mapping to better support
> skb_dma_map/skb_dma_unmap and addresses and redefines the tx hang logic to
> be based off of time stamp instead of if the dma field is populated
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


Applied.
