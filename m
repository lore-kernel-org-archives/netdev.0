From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] doc: document MSG_ZEROCOPY
Date: Fri, 1 Sep 2017 09:37:29 -0400
Message-ID: <CAF=yD-LJzvjViz-1-Wpme35Bg658XPffgVOYspufmw8LTOMmig@mail.gmail.com>
References: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com> <20170901144424.72f9c9e9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34021 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752061AbdIANiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 09:38:10 -0400
Received: by mail-oi0-f66.google.com with SMTP id w10so203824oie.1
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 06:38:10 -0700 (PDT)
In-Reply-To: <20170901144424.72f9c9e9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 1, 2017 at 8:44 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Thu, 31 Aug 2017 17:00:13 -0400
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:
>
>> +More Info
>> +---------
>> +
>> +Much of this document was derived from a longer paper presented at
>> +netdev 2.1. For more in-depth information see that paper and talk,
>> +the excellent reporting over at LWN.net or read the original code.
>> +
>> +  paper, slides, video
>> +    https://netdevconf.org/2.1/session.html?debruijn
>> +
>> +  LWN article
>> +    https://lwn.net/Articles/726917/
>> +
>> +  patchset
>> +    [PATCH net-next v4 0/9] socket sendmsg MSG_ZEROCOPY
>> +    https://lwn.net/Articles/730010/
>> +    https://www.spinics.net/lists/netdev/msg447552.html
>
> IMHO I think it would be better to use the type links also used in the
> git log.  If you look at the kernel git log, then the "Link:" tag have
> the form: http://lkml.kernel.org/r/
> And you can simply append the "Message-Id:" email header.
>
> In this case the link would be:
>   http://lkml.kernel.org/r/20170803202945.70750-1-willemdebruijn.kernel@gmail.com

I was not aware of that. Thanks, I'll send a v2.
