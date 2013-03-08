From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/4] ipv6: stop multicast forwarding to
 process interface scoped addresses
Date: Fri, 08 Mar 2013 12:28:53 -0500 (EST)
Message-ID: <20130308.122853.2065795135338373139.davem@davemloft.net>
References: <20130308120723.GA5120@order.stressinduktion.org>
	<513A121C.7010702@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756146Ab3CHR24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:28:56 -0500
In-Reply-To: <513A121C.7010702@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 09 Mar 2013 01:30:20 +0900

> Hannes Frederic Sowa wrote:
>> v2:
>> a) used struct ipv6_addr_props
>> 
>> v3:
>> a) reverted changes for ipv6_addr_props
>> 
>> v4:
>> a) do not use __ipv6_addr_needs_scope_id
>> 
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
...
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> And I think this should go to -stable as well,.

Applied to 'net' and queued up for -stable, thanks.
