From: Vinson Lee <vlee@twopensource.com>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Tue, 17 Mar 2015 16:52:20 -0700
Message-ID: <CAHTgTXX2rw9441stUb41EHTKanm9HZ+4T+a5+fur4O6G7zy21A@mail.gmail.com>
References: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
	<CAHA+R7P556Rn22qS4+CJc-RXX8ozt5uUd=dE48hSpgV9r7kvyQ@mail.gmail.com>
	<20140627.163813.1794281555636065922.davem@davemloft.net>
	<CAHA+R7N52T1NNzytbiJ0Qoc=L3tiZRJRU+8bCET-ieeih_XS8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33091 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbbCQXwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 19:52:21 -0400
Received: by oibu204 with SMTP id u204so22951721oib.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 16:52:21 -0700 (PDT)
In-Reply-To: <CAHA+R7N52T1NNzytbiJ0Qoc=L3tiZRJRU+8bCET-ieeih_XS8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 4:50 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Fri, Jun 27, 2014 at 4:38 PM, David Miller <davem@davemloft.net> wrote:
>> From: Cong Wang <cwang@twopensource.com>
>> Date: Fri, 27 Jun 2014 16:18:56 -0700
>>
>>> On Thu, Jun 19, 2014 at 4:48 PM, Cong Wang <cwang@twopensource.com> wrote:
>>>> Hi, David
>>>>
>>>>
>>>> Please consider to backport the following dev_kfree_skb_any
>>>> commits for stable. They fix some annoying warnings for us.
>>>>
>>>
>>> Any response? It looks like they are still not in your stable queue.
>>> Or do you have any objections?
>>
>> I'm too busy with other things, I'll get to it by next week.
>
> No hurry. As long as they are not lost, I am fine.
>
> Thanks for your work on stable!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi.

This stable request seems to have been forgotten.

Cheers,
Vinson
