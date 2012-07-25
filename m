From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Wed, 25 Jul 2012 12:02:08 -0300
Message-ID: <50100A70.7010605@linux.vnet.ibm.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <20120724.140353.1432900101600410863.davem@davemloft.net> <CAJZOPZKUw7DQQH5mFq4XK5GOZ_Wj6JmjFYi6no7aL_UrpO10vw@mail.gmail.com> <5010070B.5040405@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:37396 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030192Ab2GYPCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 11:02:31 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Wed, 25 Jul 2012 12:02:29 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id E12C9352004F
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 11:02:07 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6PF1LvE45809908
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 12:01:21 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6PD23gK005925
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 10:02:04 -0300
In-Reply-To: <5010070B.5040405@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2012 11:47 AM, Shlomo Pongartz wrote:

> On 7/25/2012 1:30 AM, Or Gerlitz wrote:
>> On Wed, Jul 25, 2012 at 12:03 AM, David Miller <davem@davemloft.net> wrote:
>>
>>> Or, you promised an ACK today, I still haven't seen it.
>> It turned out that reacted we did, but not the ACK way.
>>
>> Again, code review wise, we intended to ack it, but Shlomo has set
>> testing environment, under which he had some issues with the patch, as
>> such he preferred not to ACK it but rather bring up the issues on the
>> list and sort them out 1st. I thought it would be wrong to over-rule
>> this preference of him, and this way is fair-enough with the author
>> and your guide-lines, maybe I had to be more aggressive with ACKing
>> this, as of the merge window closing coming. So tomorrow.
>>
>> Or.
>>
>>> There is no reason Kleber should be penalized and have his work
>>> miss the merge window just because you guys can't be bothered
>>> to approve this patch in a reasonable amount of time.
>>>
>>> Therefore I'm just going to apply it later today, and don't do this
>>> with someone's submission ever again, it impedes progress and
>>> frustrates contributors.
>> .
>>
> 
> Hi Kleber,
> 
>  
> 
> I reviewed the patch and it seems fine, here's my ACK
> 
>  
> 
> Acked-by: Shlomo Pongratz <shlomop@mellanox.com
> <mailto:shlomop@mellanox.com>>
> 
> 


Hi Shlomo,

Thank you for reviewing my patch.

-- 
Kleber Sacilotto de Souza
IBM Linux Technology Center
