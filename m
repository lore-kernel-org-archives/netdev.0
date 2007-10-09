From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] 8021q: transfer dev_id from real device
Date: Mon, 08 Oct 2007 20:29:09 -0700 (PDT)
Message-ID: <20071008.202909.110522892.davem@davemloft.net>
References: <20071008150504.855164000@linux.vnet.ibm.com>
	<20071008150820.837583000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752443AbXJID3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 23:29:10 -0400
In-Reply-To: <20071008150820.837583000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
Date: Mon, 08 Oct 2007 17:05:05 +0200

> From: Ursula Braun <braunu@de.ibm.com>
> 
> A net_device struct provides field dev_id. It is used for
> unique ipv6 generation in case of shared network cards
> (as for the OSA network cards of IBM System z). 
> If VLAN devices are built on top of such shared network cards,
> this dev_id information needs to be transferred to the VLAN device.
> 
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>

Patch applied, thanks!
