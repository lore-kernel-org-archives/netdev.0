From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] vxlan: insert ipv6 macro
Date: Thu, 13 Oct 2016 13:30:37 +0800
Message-ID: <CAD=hENdAZX7T1f5S7f3j5k0xdrTwYp=Nc5Cn+F2RZXKA4ye3Qw@mail.gmail.com>
References: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com>
 <20161011160615.7f7f7746@griffin> <CAD=hENc0pQPKDvq_HJ14BhNzAWQndZ4GMo_-_D4EtQMgs9tv2g@mail.gmail.com>
 <20161012151638.6250dff6@griffin> <CAD=hENcp32QHB890DbnKN8QxQWbSLRcsUnE86YN-2nUZ_q7OSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pabeni@redhat.com,
        daniel@iogearbox.net, Pravin B Shelar <pshelar@nicira.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        hannes@stressinduktion.org, "David S. Miller" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:35744 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755049AbcJMFao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 01:30:44 -0400
Received: by mail-vk0-f66.google.com with SMTP id 130so584024vkg.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 22:30:38 -0700 (PDT)
In-Reply-To: <CAD=hENcp32QHB890DbnKN8QxQWbSLRcsUnE86YN-2nUZ_q7OSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Soon I will analyze the previous patch. I will let you know.

Thanks a lot.

On Thu, Oct 13, 2016 at 1:28 PM, zhuyj <zyjzyj2000@gmail.com> wrote:
>  Hi,  Jiri
>
> The dumped source code is in the attachment. Please check it. I think
> this file can explain all.
>
> If anything, please just let me know.
> Thanks a lot.
>
> On Wed, Oct 12, 2016 at 9:16 PM, Jiri Benc <jbenc@redhat.com> wrote:
>> On Wed, 12 Oct 2016 21:01:54 +0800, zhuyj wrote:
>>> How to explain the following source code? As you mentioned,  are the
>>> #ifdefs in the following source pointless?
>>
>> They are not, the code would not compile without them. Look how struct
>> vxlan_dev is defined.
>>
>> Those are really basic questions you have. I suggest you try yourself
>> before asking such questions next time. In this case, you could
>> trivially remove the #ifdef and see for yourself, as I explained in the
>> previous email. Please do not try to offload your homework to other
>> people. It's very obvious you didn't even try to understand this, even
>> after the feedback you received.
>>
>> And do not top post.
>>
>> Thanks,
>>
>>  Jiri
