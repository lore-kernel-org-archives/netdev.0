From: David Miller <davem@davemloft.net>
Subject: Re: [patch 09/13] net: add the UdpSndbufErrors and UdpRcvbufErrors
 MIBs
Date: Tue, 15 Aug 2006 00:11:11 -0700 (PDT)
Message-ID: <20060815.001111.34759918.davem@davemloft.net>
References: <200608150603.k7F63hAH012948@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbligh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28084
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965240AbWHOHLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:11:10 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63hAH012948@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:43 -0700

> From: Martin Bligh <mbligh@google.com>
> 
> Signed-off-by: Martin Bligh <mbligh@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19.

I implemented the IPv6 side since you didn't bother to.

