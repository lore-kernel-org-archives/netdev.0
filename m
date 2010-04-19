From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/11] bnx2x: Bug fixes and enhancements
Date: Mon, 19 Apr 2010 13:17:57 -0700 (PDT)
Message-ID: <20100419.131757.45886571.davem@davemloft.net>
References: <1271675582.6900.265.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751583Ab0DSURw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 16:17:52 -0400
In-Reply-To: <1271675582.6900.265.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 19 Apr 2010 14:13:02 +0300

> Resubmitting this patch series with the following changes:
> - patch 2 VPD: using generic infrastructures for VPD access
> - omitting patch 11 (disabling LRO and leaving only GRO on XEN kernel at
> compile time)
> - omitting patch 10: changing the default queues to 1 on 32 bits system.
> 
> We are looking into using kmalloc() instead of vmalloc() to overcome the
> issue on 32 bits kernels.
> 
> Please consider applying these changes to net-next.

This looks a lot better, applied to net-next-2.6 thanks!
