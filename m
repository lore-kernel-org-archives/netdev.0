From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [BNX2]: Convert to netdev_alloc_skb()
Date: Tue, 15 Aug 2006 01:40:04 -0700 (PDT)
Message-ID: <20060815.014004.112983665.davem@davemloft.net>
References: <1155255283.11815.4.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57480
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965303AbWHOIkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 04:40:02 -0400
To: mchan@broadcom.com
In-Reply-To: <1155255283.11815.4.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Aug 2006 17:14:43 -0700

> [BNX2]: Convert to netdev_alloc_skb()
> 
> Convert dev_alloc_skb() to netdev_alloc_skb() and increase default
> rx ring size to 255. The old ring size of 100 was too small.
> 
> Update version to 1.4.44.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks a lot.
