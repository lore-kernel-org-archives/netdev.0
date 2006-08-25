From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 16:11:51 -0700 (PDT)
Message-ID: <20060825.161151.64806897.davem@davemloft.net>
References: <44EEE99A.2030205@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41348
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964814AbWHYXLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:11:46 -0400
To: kaber@trash.net
In-Reply-To: <44EEE99A.2030205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 25 Aug 2006 14:14:18 +0200

> [NET_SCHED]: Add mask support to fwmark classifier
> 
> Support masking the nfmark value before the search. The mask value is
> global for all filters contained in one instance. It can only be set
> when a new instance is created, all filters must specify the same mask.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot.
