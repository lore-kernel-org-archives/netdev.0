From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 3/3] net: skb_queue_purge(): lock/unlock the queue
 only once
Date: Sat, 09 Sep 2017 09:52:49 -0700
Message-ID: <1504975969.15310.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
         <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
         <0c67e720495b4c1a920ed0f7a7e1daeb-mfwitten@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Witten <mfwitten@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35366 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757504AbdIIQww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 12:52:52 -0400
In-Reply-To: <0c67e720495b4c1a920ed0f7a7e1daeb-mfwitten@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-09-09 at 05:50 +0000, Michael Witten wrote:
> Thanks for your input, Eric Dumazet and Stephen Hemminger; based on
> your observations, this version of the patch implements a very
> lightweight purging of the queue.

net-next is closed.

Documentation/networking/netdev-FAQ.txt

Meaning we are chasing bugs at this moment, not adding new ones.

Thanks.
