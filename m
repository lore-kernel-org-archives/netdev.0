From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1e:disable NETIF_F_TSO6 for hardware limit
Date: Wed, 02 Dec 2009 00:31:51 -0800 (PST)
Message-ID: <20091202.003151.77443093.davem@davemloft.net>
References: <1259723914457-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, 558426@bugs.debian.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbZLBIbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:31:45 -0500
In-Reply-To: <1259723914457-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Wed, 2 Dec 2009 11:18:34 +0800

> From: Jie Yang <jie.yang@atheros.com>
> 
> For hardware limit to support TSOV6, just disable this feature
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Shouldn't we be applying this to net-2.6 since it's a bug fix?
