From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix opps during MTU change on an active device
Date: Thu, 19 Aug 2010 00:10:06 -0700 (PDT)
Message-ID: <20100819.001006.124071204.davem@davemloft.net>
References: <20100817191543.GA5016@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santil@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, rfolco@linux.vnet.ibm.com
To: rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111Ab0HSHJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:09:47 -0400
In-Reply-To: <20100817191543.GA5016@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jennings <rcj@linux.vnet.ibm.com>
Date: Tue, 17 Aug 2010 14:15:45 -0500

> This fixes the following opps which can occur when trying to deallocate
> receive buffer pools when changing the MTU of an active ibmveth device.
 ...
> Reported-by: Rafael Camarda Silva Folco <rfolco@linux.vnet.ibm.com>
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

Applied, thank you.
