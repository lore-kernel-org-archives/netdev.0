From: Eric Dumazet <edumazet@google.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss > window)
Date: Fri, 13 Jan 2017 09:14:38 -0800
Message-ID: <CANn89i+5m2uUBmHRHG32_oPyR53vQoG4SfOY6xWG_RNxPz6dZw@mail.gmail.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com> <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35674 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbdAMRPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:15:32 -0500
Received: by mail-io0-f182.google.com with SMTP id j18so48198382ioe.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 09:14:39 -0800 (PST)
In-Reply-To: <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 9:07 AM, Alexey Kodanev
<alexey.kodanev@oracle.com> wrote:
> Hi Eric,
> On 13.01.2017 18:35, Eric Dumazet wrote:

>> Care to send a packetdrill test so that we have a clear picture of what
>> is going on ?
>
> Is it capable of making two connections in the single test, one after
> another?

Absolutely.

Neal, Yuchung would you be kind enough to send a Fastopen tpacketdrill
template showing a typical fastopen test
running on an upstream kernel ?

Thanks !
