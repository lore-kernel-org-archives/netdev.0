From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre6: fix rtnl dump messages
Date: Fri, 09 Nov 2012 17:11:59 -0500 (EST)
Message-ID: <20121109.171159.1691681145293685667.davem@davemloft.net>
References: <1352467361.19779.569.camel@edumazet-glaptop>
	<1352475296-14675-1-git-send-email-nicolas.dichtel@6wind.com>
	<1352477346.19779.710.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab2KIWMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 17:12:01 -0500
In-Reply-To: <1352477346.19779.710.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Nov 2012 08:09:06 -0800

> On Fri, 2012-11-09 at 16:34 +0100, Nicolas Dichtel wrote:
>> Spotted after a code review.
>> Introduced by c12b395a46646bab69089ce7016ac78177f6001f (gre: Support GRE over
>> IPv6).
>> 
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>> v2: rebase the patch against net
>>     add the commit that introduces the bug
> 
> Thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
