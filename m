From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Thu, 19 Oct 2017 15:21:36 -0700
Message-ID: <CANn89iJFJPgYJjC7BGAt+x4ymsys2GCv+EYww86G8XLy1nt4ow@mail.gmail.com>
References: <1508269526.31614.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171019.133138.1755187507720163652.davem@davemloft.net> <CANn89i+=3B-i1Fo=8PWwzXJ-Tn7x8uOL7oQ02Bvx0e-KrdUQFw@mail.gmail.com>
 <20171019.230753.319918311561874519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:50406 "EHLO
        mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752342AbdJSWVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:21:37 -0400
Received: by mail-yw0-f182.google.com with SMTP id i198so4869173ywe.7
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:21:37 -0700 (PDT)
In-Reply-To: <20171019.230753.319918311561874519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 3:07 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Thu, 19 Oct 2017 07:45:09 -0700
>
>> Can you send me this v2-net-dccp-tcp-fix-ireq--opt-races.patch file ?
>>
>> Here the patch applies fine.
>
> Sure, attached.
>
> I even just tried it again, same result:
>

Thanks David.
It is completely white space mangled (tabulations replaced by spaces.)
I have no idea how it happened, but it definitely happened on my side.
I will resend, sorry for this mess.
