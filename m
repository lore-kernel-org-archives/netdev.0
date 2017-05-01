From: Joe Smith <codesoldier1@gmail.com>
Subject: Re: Question about tcp_mark_lost_retrans
Date: Mon, 1 May 2017 12:12:59 -0700
Message-ID: <CABGNecyJkN0DB0LtkKo-DaF4W-Hh_AquaY1cuC1JLHpbrx3u=A@mail.gmail.com>
References: <CABGNecwM2eDJpPLMQZZ3DCsGDO4ktsX-R43dvgTQkd1Etq+WjA@mail.gmail.com>
 <20170501.151042.1997320785999410909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33900 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdEATNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:13:00 -0400
Received: by mail-io0-f170.google.com with SMTP id a103so126939808ioj.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 12:13:00 -0700 (PDT)
In-Reply-To: <20170501.151042.1997320785999410909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Dave. I was looking at linux-stable-v4.11-rc7. I will sync up.

On Mon, May 1, 2017 at 12:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Joe Smith <codesoldier1@gmail.com>
> Date: Mon, 1 May 2017 12:01:33 -0700
>
>> static void tcp_mark_lost_retrans(struct sock *sk)
>
> This function no longer exists in the tree.



-- 
JS
