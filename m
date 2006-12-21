From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4][SCTP]: make 2 functions static
Date: Wed, 20 Dec 2006 16:08:32 -0800 (PST)
Message-ID: <20061220.160832.122606408.davem@davemloft.net>
References: <1166659266.5722.18.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161062AbWLUAId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 19:08:33 -0500
To: sri@us.ibm.com
In-Reply-To: <1166659266.5722.18.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 20 Dec 2006 16:01:06 -0800

> [SCTP]: make 2 functions static
> 
> This patch makes the following needlessly global functions static:
> - ipv6.c: sctp_inet6addr_event()
> - protocol.c: sctp_inetaddr_event()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks a lot.
