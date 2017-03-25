From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] ping: implement proper locking
Date: Fri, 24 Mar 2017 19:33:56 -0700
Message-ID: <CANn89iKqhNpvRKndbJxAXxGyfA0ER90puEzr6_QL5xhqKkU6Pg@mail.gmail.com>
References: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com> <20170324.191016.1704224805339195329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>, solar@openwall.com,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36090 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936916AbdCYCd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 22:33:59 -0400
Received: by mail-wm0-f50.google.com with SMTP id n11so25185253wma.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 19:33:58 -0700 (PDT)
In-Reply-To: <20170324.191016.1704224805339195329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 7:10 PM, David Miller <davem@davemloft.net> wrote:
>
>
> Eric, please add a proper signoff for yourself, and also please
> add the following tag:
>
> Reported-by: Daniel Jiang <danieljiang0415@gmail.com>


Oh right, will send a v2 immediately. Thanks.
