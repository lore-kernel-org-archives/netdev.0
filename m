From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] net/sched: cls_flower: Support masking for
 matching on tcp/udp ports
Date: Tue, 13 Sep 2016 16:12:05 +0200
Message-ID: <20160913141205.GB1942@nanopsycho>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
 <1473775361-16547-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33069 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758201AbcIMOMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:12:09 -0400
Received: by mail-wm0-f46.google.com with SMTP id b187so17297562wme.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 07:12:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473775361-16547-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 13, 2016 at 04:02:39PM CEST, ogerlitz@mellanox.com wrote:
>Add the definitions for src/dst udp/tcp port masks and use
>them when setting && dumping the relevant keys.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Signed-off-by: Paul Blakey <paulb@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
