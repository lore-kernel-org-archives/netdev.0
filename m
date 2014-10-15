From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] SCTP fixes
Date: Wed, 15 Oct 2014 00:21:43 -0400 (EDT)
Message-ID: <20141015.002143.780696221161706737.davem@davemloft.net>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
	<20141014.124657.128658692728989163.davem@davemloft.net>
	<20141015030631.GA6778@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaJOEVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 00:21:48 -0400
In-Reply-To: <20141015030631.GA6778@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 14 Oct 2014 23:06:32 -0400

> On Tue, Oct 14, 2014 at 12:46:57PM -0400, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Thu,  9 Oct 2014 22:55:30 +0200
>> 
>> > Here are some SCTP fixes.
>> > 
>> > [ Note, immediate workaround would be to disable ASCONF (it
>> >   is sysctl disabled by default). It is actually only used
>> >   together with chunk authentication. ]
>> 
>> Series applied, thanks guys.
> Why did you apply this Dave? There was ongoing discussion around it.

Sorry Neil, that wasn't my impression.

Worry not I can revert or apply relative fixes on top.
:-)

Thanks.
