From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing
 discipline
Date: Thu, 29 Aug 2013 22:25:19 -0400 (EDT)
Message-ID: <20130829.222519.2239357362023600080.davem@davemloft.net>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
	<521D34CC.205@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab3H3CZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 22:25:21 -0400
In-Reply-To: <521D34CC.205@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 27 Aug 2013 16:22:52 -0700

> On 08/27/2013 04:19 PM, Stephen Hemminger wrote:
>> +CoDel (codel) or fair queue CoDel (fq_codel). Dont' use queuing
>> disciplines
> 
> nit: Don't has typo above....

I fixed this when I commited Stephen's patch, thanks.
