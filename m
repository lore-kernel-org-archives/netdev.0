From: David Miller <davem@davemloft.net>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Thu, 04 Apr 2013 14:09:56 -0400 (EDT)
Message-ID: <20130404.140956.2233513394092413594.davem@davemloft.net>
References: <1364999477.13853.21.camel@edumazet-glaptop>
	<CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>
	<515D3A09.7040202@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	mkubecek@suse.cz, fengguang.wu@intel.com, isdn@linux-pingi.de,
	netdev@vger.kernel.org, joe@perches.com
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764318Ab3DDSJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 14:09:59 -0400
In-Reply-To: <515D3A09.7040202@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 04 Apr 2013 16:30:01 +0800

>> Of course, nobody sane actually cares about ISDN any more, so I think
>> this is all pretty academic. I think even Germany (where ISDN *used*
>> to be very common due to telephone monopolies and odd rules) no longer
>> uses it. I can't imagine that anybody else does either.
>> 
> 
>   can we delete it ?

I think the point is no that we can delete it, but rather that we
should concentrate our efforts on code that more people use rather
than trying to clean up antiquated code with very few users.
