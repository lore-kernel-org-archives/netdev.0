From: David Miller <davem@davemloft.net>
Subject: Re: neighbor vs neighbour
Date: Thu, 25 Jun 2009 16:43:00 -0700 (PDT)
Message-ID: <20090625.164300.122694728.davem@davemloft.net>
References: <200906251431.34677.bcook@bpointsys.com>
	<200906251522.08095.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcook@bpointsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752610AbZFYXmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 19:42:55 -0400
In-Reply-To: <200906251522.08095.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brent Cook <bcook@bpointsys.com>
Date: Thu, 25 Jun 2009 15:22:07 -0500

> On Thursday 25 June 2009 02:31:34 pm Brent Cook wrote:
>> I was looking at netstat -6 -s to debug a routing issue, and noticed that
>> the output is a little confusing. What's the difference between 'neighbor
>> solicits' and 'neighbour solicits'. And yes, I've already hear the
>> 'Atlantic Ocean' joke :) Is one TX vs RX?
> 
> Just checked the source - neighbour is In, neighbor is Out. Looks like a net-
> tools issue, I'll take it off-list.

Thanks for investigating this.
