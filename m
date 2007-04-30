From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] [IPV4] SNMP: Support InTruncatedPkts
Date: Mon, 30 Apr 2007 00:49:14 -0700 (PDT)
Message-ID: <20070430.004914.08651682.davem@davemloft.net>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201337.3d48b86a.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423133AbXD3HtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:49:17 -0400
In-Reply-To: <20070417201337.3d48b86a.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2007 20:13:37 +0900

> An IP datagram which is being discarded because the datagram frame
> didn't carry enough data should be counted as InTruncatedPkts.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Applied, thanks.
