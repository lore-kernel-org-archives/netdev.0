From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] MAINTAINERS: PHY: Change maintainer to reviewer
Date: Wed, 25 Nov 2015 10:07:25 -0800
Message-ID: <5655F8DD.3000405@gmail.com>
References: <1448407790-22336-1-git-send-email-f.fainelli@gmail.com>	<1448413451.20113.20.camel@perches.com> <20151125.113602.515197415619267019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36441 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbbKYSIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 13:08:31 -0500
Received: by pacdm15 with SMTP id dm15so64143584pac.3
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 10:08:31 -0800 (PST)
In-Reply-To: <20151125.113602.515197415619267019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/15 08:36, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 24 Nov 2015 17:04:11 -0800
> 
>> On Tue, 2015-11-24 at 15:29 -0800, Florian Fainelli wrote:
>>> Now that there is a reviewer role, add myself as reviewer since the PHY
>>> library code is maintained via the networking tree.
>>
>> []
>>
>>> diff --git a/MAINTAINERS b/MAINTAINERS
>> []
>>> @@ -4195,7 +4195,7 @@ F:	include/linux/netfilter_bridge/
>>>  F:> 	> net/bridge/
>>>  
>>>  ETHERNET PHY LIBRARY
>>> -M:	Florian Fainelli <f.fainelli@gmail.com>
>>> +R:	Florian Fainelli <f.fainelli@gmail.com>
>>>  L:	netdev@vger.kernel.org
>>>  S:	Maintained
>>>  F:	include/linux/phy.h
>>
>> Just because the upstream path is not a tree you
>> manage doesn't mean you aren't a maintainer.
>>
>> I think the status should be something other than
>> "Maintained" if you are not the maintainer.
> 
> Yeah, I kinda agree, Florian you are pretty much the de-facto
> maintainer and I usually wait for you to review any PHY library
> changes before applying them unless they are _really_ obvious.

Sounds good, let's drop this patch then, thanks!
-- 
Florian
