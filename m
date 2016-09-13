From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] net/sched: cls_flower: Specify vlan
 attributes format in the UAPI header
Date: Tue, 13 Sep 2016 16:21:14 +0200
Message-ID: <20160913142114.GD1942@nanopsycho>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
 <1473775361-16547-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34483 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758587AbcIMOVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:21:17 -0400
Received: by mail-wm0-f67.google.com with SMTP id g141so7550965wmd.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 07:21:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473775361-16547-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 13, 2016 at 04:02:41PM CEST, ogerlitz@mellanox.com wrote:
>Specify the format (size and endianess) for the vlan attributes.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
