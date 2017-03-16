From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V2 0/2] small set of sched cleanups
Date: Thu, 16 Mar 2017 13:29:26 -0700
Message-ID: <CAM_iQpVFe9QMmqzqbx5VO1GqhLf6xRm7Z259ZHskLsZqJBeLGQ@mail.gmail.com>
References: <1489661622-14498-1-git-send-email-ogerlitz@mellanox.com> <20170316.120251.2226435343527873265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36494 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdCPU3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 16:29:49 -0400
Received: by mail-wm0-f44.google.com with SMTP id n11so1174357wma.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 13:29:47 -0700 (PDT)
In-Reply-To: <20170316.120251.2226435343527873265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 12:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu, 16 Mar 2017 12:53:40 +0200
>
>> Just two cleanups -- but for the 2nd one I think we need ack from
>> Cong Wang to make sure this isn't actually a bug report..
>  ...
>> changes from V1:
>>   - addressed comment from Sergei to use 12 hex digits etc
>
> Series applied since Eric Dumazet reviewed and ACK's patch #2,
> although I still want Cong to take a look at it.

I already did and gave an Ack. Is it lost?
