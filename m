From: David Miller <davem@davemloft.net>
Subject: Re: net-next is OPEN
Date: Thu, 09 Jul 2015 10:40:19 -0700 (PDT)
Message-ID: <20150709.104019.370940061164391476.davem@davemloft.net>
References: <20150708.133041.2042093870138764891.davem@davemloft.net>
	<559E5FCE.6010301@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbbGIRkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 13:40:20 -0400
In-Reply-To: <559E5FCE.6010301@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 9 Jul 2015 14:49:34 +0300

> Hello.
> 
> On 7/8/2015 11:30 PM, David Miller wrote:
> 
>> Please feel free to bombard me with net-next changes, which some of
>> you
>> have been doing already ;-(, as net-next is now open.
> 
>    Hm, I pulled and didn't see 4.2-rc1 tag. Is it normal?

Why does it have to be there?

I build net-next by pulling net into net-next.

Since 'net' is based upon Linus's tree before he added that tag
there is no reason for it to have that tag at all.

I really have no idea why you expect it to be there.
