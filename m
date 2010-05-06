From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: reduce cache misses on tx cleanup
Date: Thu, 06 May 2010 00:36:19 -0700 (PDT)
Message-ID: <20100506.003619.232904762.davem@davemloft.net>
References: <20100505075733.5474.37834.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752946Ab0EFHgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:36:12 -0400
In-Reply-To: <20100505075733.5474.37834.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 00:58:07 -0700

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> This patch reduces the number of skb cache misses in the
> clean_tx_irq path, and results in an overall increase
> in tx packet throughput.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
