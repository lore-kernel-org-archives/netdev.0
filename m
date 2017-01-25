From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 10:54:50 -0800
Message-ID: <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
References: <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170124191127.GG21921@1wt.eu> <CAC15z3izWNh7th_yxA_a90vgLnU5XzVDm6vyojq3cMDgQZ71YA@mail.gmail.com>
 <20170125.122205.9460825196595773.davem@davemloft.net> <20170125175458.GF23545@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33480 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdAYSzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:55:16 -0500
Received: by mail-qt0-f195.google.com with SMTP id n13so32985644qtc.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 10:54:57 -0800 (PST)
In-Reply-To: <20170125175458.GF23545@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes sorry David, for me it's OK. If Wei runs his whole series of tests
> on it again, it should be perfect.

I just ran all the TFO related tests with Willy's patch on top of this
patch series.
And everything passes.

On Wed, Jan 25, 2017 at 9:54 AM, Willy Tarreau <w@1wt.eu> wrote:
> On Wed, Jan 25, 2017 at 12:22:05PM -0500, David Miller wrote:
>> From: Wei Wang <tracywwnj@gmail.com>
>> Date: Wed, 25 Jan 2017 09:15:34 -0800
>>
>> > Looks like you sent a separate patch on top of this patch series to
>> > address double connect().  Then I think this patch series should be
>> > good to go.
>>
>> Indeed, Willy please give some kind of ACK.
>
> Yes sorry David, for me it's OK. If Wei runs his whole series of tests
> on it again, it should be perfect.
>
> thanks,
> Willy
