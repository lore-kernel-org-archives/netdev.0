From: Cong Wang <cwang@twopensource.com>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Fri, 27 Jun 2014 16:50:03 -0700
Message-ID: <CAHA+R7N52T1NNzytbiJ0Qoc=L3tiZRJRU+8bCET-ieeih_XS8Q@mail.gmail.com>
References: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
	<CAHA+R7P556Rn22qS4+CJc-RXX8ozt5uUd=dE48hSpgV9r7kvyQ@mail.gmail.com>
	<20140627.163813.1794281555636065922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:61277 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaF0XuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:50:06 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so3477137lab.27
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 16:50:03 -0700 (PDT)
In-Reply-To: <20140627.163813.1794281555636065922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 4:38 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Fri, 27 Jun 2014 16:18:56 -0700
>
>> On Thu, Jun 19, 2014 at 4:48 PM, Cong Wang <cwang@twopensource.com> wrote:
>>> Hi, David
>>>
>>>
>>> Please consider to backport the following dev_kfree_skb_any
>>> commits for stable. They fix some annoying warnings for us.
>>>
>>
>> Any response? It looks like they are still not in your stable queue.
>> Or do you have any objections?
>
> I'm too busy with other things, I'll get to it by next week.

No hurry. As long as they are not lost, I am fine.

Thanks for your work on stable!
