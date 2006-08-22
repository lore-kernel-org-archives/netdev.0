From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5][SCTP]: Cleanup nomem handling in the state
 functions.
Date: Tue, 22 Aug 2006 00:21:29 -0700 (PDT)
Message-ID: <20060822.002129.35353207.davem@davemloft.net>
References: <1155925353.20802.26.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46562
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751311AbWHVHVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:21:15 -0400
To: sri@us.ibm.com
In-Reply-To: <1155925353.20802.26.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 18 Aug 2006 11:22:33 -0700

> [SCTP]: Cleanup nomem handling in the state functions.
> 
> This patch cleans up the "nomem" conditions that may occur during the
> processing by the state machine functions. In most cases we delay adding
> side-effect commands until all memory allocations are done.
> 
> Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
