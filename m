From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv4] SNMP: Refer correct memory location to display
 ICMP out-going statistics
Date: Mon, 29 Oct 2007 22:03:44 -0700 (PDT)
Message-ID: <20071029.220344.202688568.davem@davemloft.net>
References: <20071026105928.d56cd244.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbXJ3FDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 01:03:48 -0400
In-Reply-To: <20071026105928.d56cd244.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Fri, 26 Oct 2007 10:59:28 +0900

> While displaying ICMP out-going statistics as Out<name> counters in
> /proc/net/snmp, the memory location for ICMP in-coming statistics
> was referred by mistake.
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Patch applied, thank you!
