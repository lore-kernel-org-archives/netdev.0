From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] SCTP update
Date: Wed, 11 Jun 2014 12:23:48 -0700 (PDT)
Message-ID: <20140611.122348.373246436230074482.davem@davemloft.net>
References: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
	<539882C0.3000209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbaFKTXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 15:23:50 -0400
In-Reply-To: <539882C0.3000209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Wed, 11 Jun 2014 12:24:32 -0400

> On 06/11/2014 12:19 PM, Daniel Borkmann wrote:
>> This set contains transport path selection improvements in
>> SCTP. Please see individual patches for details.
>> 
>> Thanks!
>> 
>> v2->v3:
>>  - Reworded commit message in patch 4, thanks Vlad!
>> v1->v2:
>>  - Fixed a typo in a comment in patch 1, thanks Florian Westphal
>>    for pointing this out, rest stays as is.
>> 
>> Daniel Borkmann (5):
>>   ktime: add ktime_after and ktime_before helper
>>   net: sctp: refactor active path selection
>>   net: sctp: migrate most recently used transport to ktime
>>   net: sctp: improve sctp_select_active_and_retran_path selection
>>   net: sctp: fix incorrect type in gfp initializer
>> 
> 
> Series
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied to net-next, thanks everyone.
