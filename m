From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2014-08-01
Date: Mon, 04 Aug 2014 22:57:29 -0700 (PDT)
Message-ID: <20140804.225729.663353171881658413.davem@davemloft.net>
References: <C2EB98EF-6873-4F44-B914-A9F89146914A@holtmann.org>
	<20140804145342.GB16658@tuxdriver.com>
	<ED6BF15D-CA1F-4E35-8301-E9A9EEDE3AD6@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569AbaHEF5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 01:57:30 -0400
In-Reply-To: <ED6BF15D-CA1F-4E35-8301-E9A9EEDE3AD6@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 4 Aug 2014 22:39:47 -0700

> Hi Dave,
> 
>>>>> Please pull this last(?) batch of wireless change intended for the
>>>>> 3.17 stream...
>>>> 
>>>> When I pull this I get tons of conflicts for:
>>>> 
>>>> CONFLICT (content): Merge conflict in net/6lowpan/iphc.c
>>>> 
>>>> I don't feel comfortable fixing these up, where are they coming
>>>> from?
>>> 
>>> I was short on time yesterday, but now I checked up on this in detail. The merge conflicts are actually simple to resolve. You can just rely on John's tree to have the more recent net/6lowpan/ tree. I should have insisted on merging net/6lowpan/ through bluetooth-next and wireless-next way earlier to avoid conflicts.
>>> 
>>> In the future we will avoid this by ensuring that all goes via bluetooth-next first. Sorry for this confusion. John mentioned these merge conflicts in his footnote.
>>> 
>>> John, do you just want to resolve the merge conflicts and send Dave a new pull request?
>> 
>> I'm happy to do that, if Dave wants.  But as you say, once the initial
>> shock of all those conflicts passes the resolution really is fairly
>> simple. :-)
> 
> do you want John to just do the merge conflict resolution? They are all trivial.

I am going to try and do it myself, I just haven't gotten around to it.

Thanks for asking.
