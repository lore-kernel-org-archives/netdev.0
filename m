From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter updates for net-next
Date: Tue, 13 Nov 2012 14:12:59 -0500 (EST)
Message-ID: <20121113.141259.920173818208682329.davem@davemloft.net>
References: <1352765203-4160-1-git-send-email-pablo@netfilter.org>
	<20121113124002.GA5350@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab2KMTNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:13:01 -0500
In-Reply-To: <20121113124002.GA5350@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 13 Nov 2012 13:40:02 +0100

> On Tue, Nov 13, 2012 at 01:06:40AM +0100, pablo@netfilter.org wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> 
>> Hi David,
>> 
>> The following three patches contain updates for your net-next tree,
>> they include:
>> 
>> * Little cleanup for IPVS the use of a strange notation to assign the
>>   conntrack object, from Alan Cox.
>> 
>> * getsockopt support to obtain the original IPv6 address after NAT,
>>   similar to the one that IPv4 provides, from Florian Westphal.
>> 
>> * Another little cleanup for nf_nat to save a couple of lines by using
>>   PTR_RET, from Wu Fengguang.
> 
> Please, hold on with this pull request. We need a follow-up patch to
> resolve an issue regarding the getsockopt to obtain original address
> with IPv6 NAT.
> 
> I'll send you a new pull request.

Ok.
