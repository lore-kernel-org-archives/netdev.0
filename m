From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] net/sched: cls_flower: Remove an unsed field
 from the filter key structure
Date: Thu, 15 Sep 2016 15:01:23 +0300
Message-ID: <a1d1551b-6eb8-df01-37e8-255cf1849987@cogentembedded.com>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
 <1473775361-16547-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32905 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934778AbcIOMB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:01:27 -0400
Received: by mail-lf0-f54.google.com with SMTP id h127so32298065lfh.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 05:01:26 -0700 (PDT)
In-Reply-To: <1473775361-16547-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2016 5:02 PM, Or Gerlitz wrote:

> Commit c3f8324188fa "net: Add full IPv6 addresses to flow_keys" added an
> unsed instance of struct flow_dissector_key_addrs into struct fl_flow_key,

    Unused?

> remove it.
>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Hadar Hen Zion <hadarh@mellanox.com>
[...]

MBR, Sergei
