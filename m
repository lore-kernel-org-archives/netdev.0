From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 18:00:49 -0500
Message-ID: <52B4CC21.8030801@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>	<CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>	<52B434A9.9070408@mojatatu.com>	<CAM_iQpWz0NP_6vtYhHSSDW1p3HdALoiNm7JkwL=1-XErHOZ14w@mail.gmail.com>	<52B4A6C0.605@mojatatu.com> <CAM_iQpXaDtfTFzgcGih1weWAxLqmcgHMHBP0bU9M5mnYdjPkaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:40638 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab3LTXBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:01:07 -0500
Received: by mail-ig0-f174.google.com with SMTP id hk11so16384500igb.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:01:04 -0800 (PST)
In-Reply-To: <CAM_iQpXaDtfTFzgcGih1weWAxLqmcgHMHBP0bU9M5mnYdjPkaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 16:36, Cong Wang wrote:
> On Fri, Dec 20, 2013 at 12:21 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>
>>> It is in my test case right after David merged it,
>>> I still don't see any bug it reports so far.
>>>
>>
>> Run before your changes and after your changes and
>> it will be obvious.
>>
>
> I thought we were still talking about the crash Eric reported. :)
>

You lost me.
You said you were running all those tests and didnt see any
bugs. I said if infact you ran exactly what you said you test
did before and after your changes you will see obvious bugs.

cheers,
jamal
