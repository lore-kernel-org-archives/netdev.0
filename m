From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: comment spelling fixes
Date: Tue, 22 Nov 2011 16:38:00 -0500 (EST)
Message-ID: <20111122.163800.290426826465603259.davem@davemloft.net>
References: <20111121085346.2203c4f4@nehalam.linuxnetplumber.net>
	<1321895528.2692.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831Ab1KVViE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:38:04 -0500
In-Reply-To: <1321895528.2692.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 21 Nov 2011 17:12:08 +0000

> On Mon, 2011-11-21 at 08:53 -0800, Stephen Hemminger wrote:
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> --- a/include/linux/pkt_sched.h	2011-11-09 13:54:59.780009551 -0800
>> +++ b/include/linux/pkt_sched.h	2011-11-21 08:51:20.062228855 -0800
>> @@ -30,7 +30,7 @@
>>   */
>>  
>>  struct tc_stats {
>> -	__u64	bytes;			/* NUmber of enqueues bytes */
>> +	__u64	bytes;			/* Number of enqueues bytes */
> [...]
> 
> Further fix needed: 'enqueued'.

I took care of this when applying Stephen's patch.
