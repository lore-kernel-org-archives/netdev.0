From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Some SCTP cleanups/improvements
Date: Fri, 14 Jun 2013 15:37:46 -0700 (PDT)
Message-ID: <20130614.153746.1697515927497882181.davem@davemloft.net>
References: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
	<51BB4C46.2080506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab3FNWhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:37:46 -0400
In-Reply-To: <51BB4C46.2080506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 14 Jun 2013 13:00:54 -0400

> On 06/14/2013 12:24 PM, Daniel Borkmann wrote:
>> v2 -> v3:
>>    - Applied feedback from Vlad in first patch, rest is unchanged
>>
>> v1 -> v2:
>>    - Applied Neil's feedback, I'll send out the first patch at a later
>>      point in time though, have not included it in this set
>>    - Add two other patches that appear to be useful from the last
>>      couple of days debugging SCTP code
>>
>> Let it run through lksctp-tools and also my recent stress test tool,
>> all looks good.
> 
> Looks good.
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Series applied, thanks.
