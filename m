From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][SCTP]: Increment error counters on user requested
 HBs.
Date: Mon, 19 Mar 2007 17:02:54 -0700 (PDT)
Message-ID: <20070319.170254.85414711.davem@davemloft.net>
References: <1174329490.3187.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030775AbXCTACz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 20:02:55 -0400
In-Reply-To: <1174329490.3187.13.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 19 Mar 2007 11:38:10 -0700

> [SCTP]: Increment error counters on user requested HBs.
> 
> 2960bis states (Section 8.3):
> 
>    D) Request an on-demand HEARTBEAT on a specific destination transport
>       address of a given association.
> 
>    The endpoint should increment the respective error counter of the
>    destination transport address each time a HEARTBEAT is sent to that
>    address and not acknowledged within one RTO.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
