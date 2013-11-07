From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Thu, 7 Nov 2013 21:18:42 +0100
Message-ID: <20131107201842.GC14694@redhat.com>
References: <20131019205222.GA18874@redhat.com>
 <20131019.184411.2017497732906948451.davem@davemloft.net>
 <20131107142418.GL19702@redhat.com>
 <20131107.151212.489598950578675166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: thomas@glanzmann.de, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, nikolay@redhat.com, robbat2@gentoo.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab3KGUU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 15:20:59 -0500
Content-Disposition: inline
In-Reply-To: <20131107.151212.489598950578675166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 03:12:12PM -0500, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Thu, 7 Nov 2013 15:24:18 +0100
>
>> Sorry for bringing this up - completely my fault. There are further
>> reports
>> of this bug in mainline. I've read the
>> ./Documentation/networking/netdev-FAQ.txt but haven't seen a way to
>> get a
>> fix that got in net-next to the (correct) net tree.
>>
>> Is there any way to do it?
>>
>> Sorry again for the mess :-(.
>
>Since we're in the merge window the tree going to Linus next would
>be net-next, and the fix is there.
>
>Once it hits Linus's tree I can queue it up for -stable.

Awesome, please do, thank you.

And sorry again for the noise.

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
