From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] iproute2: lib/utils.c bug fixes
Date: Sun, 14 Apr 2013 15:37:57 -0400 (EDT)
Message-ID: <20130414.153757.184767995109023071.davem@davemloft.net>
References: <516AB8EE.5090901@googlemail.com>
	<20130414100000.3b73fa36@nehalam.linuxnetplumber.net>
	<516B04BE.6030302@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: mr.dash.four@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab3DNTh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:37:59 -0400
In-Reply-To: <516B04BE.6030302@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dash Four <mr.dash.four@googlemail.com>
Date: Sun, 14 Apr 2013 20:34:22 +0100

> 
>> Thanks for your patch. there were lots of related over/underflow
>> errors in
>> this code which have existed for a long time. I took your patch as
>> motivation
>> and did multiple fixes to add error checking for all the cases
>> present.
>>   
> That's good. Do you have the git url (or any other repository I could
> fetch these from) so that I could apply these changes on our machines
> here? I checked on
> http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git
> but it looks as though the last commit was done 41 hours ago.

It's the top commit in his master branch, no special URL is necessary:

http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=697ac63905cb5ca5389cd840462ee9868123b77f

The commit was made two days ago.
