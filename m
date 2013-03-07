From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bridge: add missing vid to br_mdb_get()
Date: Thu, 07 Mar 2013 16:34:43 -0500 (EST)
Message-ID: <20130307.163443.702280434652702173.davem@davemloft.net>
References: <1362661533-29192-1-git-send-email-amwang@redhat.com>
	<5138AFBC.4070303@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759843Ab3CGVep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:34:45 -0500
In-Reply-To: <5138AFBC.4070303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 07 Mar 2013 10:18:20 -0500

> On 03/07/2013 08:05 AM, Cong Wang wrote:
>> From: Cong Wang <amwang@redhat.com>
>>
>> Obviously, vid should be considered when searching for multicast
>> group.
>>
>> Cc: Vlad Yasevich <vyasevic@redhat.com>
> 
> Don't know how I missied that...
> 
> Acked-by: Vlad Yasevich <vyasevich@redhat.com>
> 
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
