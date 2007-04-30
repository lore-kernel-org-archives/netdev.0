From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] [IPV4] SNMP: Support InMcastPkts and InBcastPkts
Date: Mon, 30 Apr 2007 00:49:22 -0700 (PDT)
Message-ID: <20070430.004922.42906064.davem@davemloft.net>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201356.024b764d.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57653
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423139AbXD3HtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:49:25 -0400
In-Reply-To: <20070417201356.024b764d.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2007 20:13:56 +0900

> A received IP multicast datagram should be counted as InMcastPkts.
> By the same token, a received IP broadcast datagram should be
> counted as InBcastPkts.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Patch applied.
