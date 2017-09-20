From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Wed, 20 Sep 2017 11:03:52 -0700
Message-ID: <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-9-tom@quantonium.net>
 <20170918.211952.1397675528248642600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:53949 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdITSDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:03:54 -0400
Received: by mail-qk0-f175.google.com with SMTP id t184so3513981qke.10
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:03:54 -0700 (PDT)
In-Reply-To: <20170918.211952.1397675528248642600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Mon, 18 Sep 2017 17:38:58 -0700
>
>> Allow peers to be specified by IPv6 addresses.
>>
>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>
> Hmmm, can you just check the socket family or something like that?

I'm not sure what code you're referring to.

Thanks
