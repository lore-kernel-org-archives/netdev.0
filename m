From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] MAINTAINERS: PHY: Change maintainer to
 reviewer
Date: Wed, 25 Nov 2015 11:36:02 -0500 (EST)
Message-ID: <20151125.113602.515197415619267019.davem@davemloft.net>
References: <1448407790-22336-1-git-send-email-f.fainelli@gmail.com>
	<1448413451.20113.20.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbKYQgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:36:03 -0500
In-Reply-To: <1448413451.20113.20.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 24 Nov 2015 17:04:11 -0800

> On Tue, 2015-11-24 at 15:29 -0800, Florian Fainelli wrote:
>> Now that there is a reviewer role, add myself as reviewer since the PHY
>> library code is maintained via the networking tree.
> 
> []
> 
>> diff --git a/MAINTAINERS b/MAINTAINERS
> []
>> @@ -4195,7 +4195,7 @@ F:	include/linux/netfilter_bridge/
>>  F:> 	> net/bridge/
>>  
>>  ETHERNET PHY LIBRARY
>> -M:	Florian Fainelli <f.fainelli@gmail.com>
>> +R:	Florian Fainelli <f.fainelli@gmail.com>
>>  L:	netdev@vger.kernel.org
>>  S:	Maintained
>>  F:	include/linux/phy.h
> 
> Just because the upstream path is not a tree you
> manage doesn't mean you aren't a maintainer.
> 
> I think the status should be something other than
> "Maintained" if you are not the maintainer.

Yeah, I kinda agree, Florian you are pretty much the de-facto
maintainer and I usually wait for you to review any PHY library
changes before applying them unless they are _really_ obvious.
