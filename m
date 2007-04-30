From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [IPV4] SNMP: Support OutMcastPkts and OutBcastPkts
Date: Mon, 30 Apr 2007 00:49:29 -0700 (PDT)
Message-ID: <20070430.004929.88344864.davem@davemloft.net>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201418.e6f1a379.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57654
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423132AbXD3Htc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:49:32 -0400
In-Reply-To: <20070417201418.e6f1a379.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2007 20:14:18 +0900

> A transmitted IP multicast datagram should be counted as OutMcastPkts.
> By the same token, a transmitted IP broadcast datagram should be
> counted as OutBcastPkts.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Patch applied, thanks.
