From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5][SCTP]: Fix IPv6 address flag setting when doing
 peel-off/accept.
Date: Tue, 22 Aug 2006 00:23:26 -0700 (PDT)
Message-ID: <20060822.002326.82048894.davem@davemloft.net>
References: <1155925362.20802.28.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1456
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751329AbWHVHXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:23:11 -0400
To: sri@us.ibm.com
In-Reply-To: <1155925362.20802.28.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 18 Aug 2006 11:22:42 -0700

> [SCTP]: Fix IPv6 address flag setting when doing peel-off/accept.
> 
> During accept/peeloff we try to copy the list of bound addresses from
> the original endpoint to the new one. However, we forgot to set the flag
> to say that IPv6 is allowed on the new endpoint.
> 
> Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
