From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] change netfilter tunables to __read_mostly
Date: Fri, 01 Sep 2006 13:39:31 -0400
Message-ID: <44F87053.2040607@hp.com>
References: <44F85276.1020804@hp.com> <44F861D4.9050208@trash.net> <44F8633F.3000302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:13223 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751277AbWIARje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 13:39:34 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44F8633F.3000302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Brian Haley wrote:
>>
>>> Change some netfilter tunables to __read_mostly.  Also fixed some
>>> incorrect file reference comments while I was in there.
>>
>> Please send these kind of patches for netfilter to me so I can
>> make sure they don't clash with other pending patches.
>>
>>
>>> (this will be my last __read_mostly patch unless someone points out
>>> something else that needs it)
>>
>> This seems to be a bit random, there are quite a few more candidates for
>> __read_mostly right next to the ones you marked.
> 
> 
> Ah sorry, I didn't really get why you chose these :)
> 
> The patch doesn't clash with anything in my queue, so ACK from me.

Sorry, next time I'll send them to you, or 
netfilter-devel@lists.netfilter.org?  I'll cook-up another patch for the 
others you mentioned and send it out.

-Brian
