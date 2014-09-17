From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] net: sched: cls_u32: rcu can not be last node
Date: Wed, 17 Sep 2014 10:31:40 -0700
Message-ID: <5419C57C.4020907@gmail.com>
References: <20140917053434.2833.66129.stgit@nitbit.x32> <541921FD.1090203@hartkopp.net> <CAM_iQpW1AOgKqQXwh2BNMH_GypTVX6NgyQJZ7Mby0kABjbBu4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:62168 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801AbaIQRb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 13:31:59 -0400
Received: by mail-oa0-f41.google.com with SMTP id o6so1508471oag.14
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 10:31:59 -0700 (PDT)
In-Reply-To: <CAM_iQpW1AOgKqQXwh2BNMH_GypTVX6NgyQJZ7Mby0kABjbBu4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2014 09:40 AM, Cong Wang wrote:
> On Tue, Sep 16, 2014 at 10:54 PM, Oliver Hartkopp
> <socketcan@hartkopp.net> wrote:
>> Please add an appropriate comment to the *code* to prevent this knowledge to
>> disappear. No one will search/find this in git commit messages next time.
>>
>
> +1
>
> Even though I dig git log, I agree adding a one-line comment is better.
>

Sure I'll add a comment at the end of the structure.

Thanks.

-- 
John Fastabend         Intel Corporation
