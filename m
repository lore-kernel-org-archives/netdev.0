From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] net/sched: cls_flower: Remove an unsed
 field from the filter key structure
Date: Tue, 13 Sep 2016 16:20:53 +0200
Message-ID: <20160913142053.GC1942@nanopsycho>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
 <1473775361-16547-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34228 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758553AbcIMOU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:20:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id g141so7549429wmd.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 07:20:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473775361-16547-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 13, 2016 at 04:02:40PM CEST, ogerlitz@mellanox.com wrote:
>Commit c3f8324188fa "net: Add full IPv6 addresses to flow_keys" added an
>unsed instance of struct flow_dissector_key_addrs into struct fl_flow_key,
>remove it.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Reported-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
