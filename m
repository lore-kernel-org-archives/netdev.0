From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scsi_netlink: Remove dead and buggy code
Date: Thu, 13 Sep 2012 16:24:57 -0400 (EDT)
Message-ID: <20120913.162457.81364799304138498.davem@davemloft.net>
References: <1347314879.3038.74.camel@dabdike.int.hansenpartnership.com>
	<878vcggp4n.fsf@xmission.com>
	<20120911.184846.1973557158791638595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org,
	James.Smart@Emulex.Com, linux-scsi@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab2IMUY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:24:59 -0400
In-Reply-To: <20120911.184846.1973557158791638595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 11 Sep 2012 18:48:46 -0400 (EDT)

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 11 Sep 2012 15:40:08 -0700
> 
>> So just for curiosity I searched the entire git history for scsi_nl_add_
>> and the only commit that I found was the addition of that code to the
>> tree in August of 2008.
>> 
>> Does anyone have any reason to keep scsi_nl_add_transport or
>> scsi_nl_add_driver that have never been used in the 4 years since
>> they have been added?
> 
> That's basically the question on the table right now :-)

Time has run out.

Letting legitimate and reasonable patches simply rot for a week is
absolutely never acceptable, so I'm applying Eric's patch to net-next.
