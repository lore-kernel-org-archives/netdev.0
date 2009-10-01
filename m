From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 21:39:32 +0300
Message-ID: <200910012139.32070.opurdila@ixiacom.com>
References: <200910011916.40908.cratiu@ixiacom.com> <200910012108.41071.cratiu@ixiacom.com> <20091001111450.221969cc@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cosmin Ratiu <cratiu@ixiacom.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23092 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752254AbZJASmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 14:42:12 -0400
In-Reply-To: <20091001111450.221969cc@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 October 2009 21:14:50 you wrote:
> 
> Probably this should be a per interface property rather than per namespace.

In our case, where we have lots of interfaces active, it would be nice to have 
the per namespace property as well.

But, as Cosmin suggested, perhaps it would be better to just send this options 
by default? (its a RFC SHOULD after all...)

Thanks,
tavi
 
