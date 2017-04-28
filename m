From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: ensure message length for raw socket is at least
 sizeof(ipv6hdr)
Date: Fri, 28 Apr 2017 10:32:30 -0400 (EDT)
Message-ID: <20170428.103230.1589857235794728290.davem@davemloft.net>
References: <CAG_fn=Xw-WTn4AsyNaaLMRaW1xqo1QOyp7JpYOW=z+hqpWdwLQ@mail.gmail.com>
        <CAG_fn=U--Ctc7mzy6J7Cvzie-ieysco0mWnPP8H+L_BO=Ci+-Q@mail.gmail.com>
        <CAG_fn=V_3UYfFFdtrVGMtUzf_wqNeMDfKA__Kwzd3pDAdu1svA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164449AbdD1Ocd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 10:32:33 -0400
In-Reply-To: <CAG_fn=V_3UYfFFdtrVGMtUzf_wqNeMDfKA__Kwzd3pDAdu1svA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Fri, 28 Apr 2017 16:28:12 +0200

> I'll send the updated patch next week.

Great, thanks for doing all of this work.
