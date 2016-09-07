From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V6 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 07 Sep 2016 10:00:22 -0700
Message-ID: <1473267622.10725.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com>
         <1473235686-18975-5-git-send-email-hadarh@mellanox.com>
         <1473257660.10725.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUDqM4s4+VYpyPXhrFE4vTuEQorj2_nJrtM75y548hDHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34554 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbcIGRAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 13:00:24 -0400
Received: by mail-pa0-f67.google.com with SMTP id gi6so1154799pac.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 10:00:24 -0700 (PDT)
In-Reply-To: <CAM_iQpUDqM4s4+VYpyPXhrFE4vTuEQorj2_nJrtM75y548hDHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 09:27 -0700, Cong Wang wrote:

> Fix checkpatch.pl (or whatever tool you prefer).

I do not use checkpatch.pl.

But I know for sure David cares about this ordering.

https://lkml.org/lkml/2016/4/24/91

https://patchwork.ozlabs.org/patch/629958/


So feel free to fix checkpatch.pl 
