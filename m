From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net] Open vSwitch
Date: Thu, 18 Apr 2013 00:22:35 -0400 (EDT)
Message-ID: <20130418.002235.1823396987873645571.davem@davemloft.net>
References: <20130416.165302.1176077619833617294.davem@davemloft.net>
	<CAEP_g=9+YqhrpyCMn=b583iT6Kt+ZTWfRVJd0Kdb4bzjqcPkPQ@mail.gmail.com>
	<20130417.223741.1218143575817775286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab3DREWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 00:22:39 -0400
In-Reply-To: <20130417.223741.1218143575817775286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 17 Apr 2013 22:37:41 -0400 (EDT)

> From: Jesse Gross <jesse@nicira.com>
> Date: Wed, 17 Apr 2013 19:31:41 -0700
> 
>> On Tue, Apr 16, 2013 at 1:53 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Jesse Gross <jesse@nicira.com>
>>> Date: Tue, 16 Apr 2013 13:17:27 -0700
>>>
>>>> Two small bug fixes for net/3.9 including the issue previously
>>>> discussed where allocation of netlink notifications can fail after
>>>> changes have been committed.
>>>
>>> Looks good, pulled, thanks!
>> 
>> Sorry, but can you check whether this was pulled correctly? I'm not
>> seeing it in your net tree.
> 
> I don't see it either.
> 
> It might be sitting locally on a computer I'm not physically in front
> of right now, I'll check when I next go there (either tonight or
> tomorrow).
> 
> Sorry!

Yes, that's exactly what happened, I forgot to push out right before
leaving this machine yesterday.

I've fixed this up and pushed it all back out to 'net'.
