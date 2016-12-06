From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 1/2] net/sched: cls_flower: Add support for
 matching on flags
Date: Tue, 6 Dec 2016 16:28:26 +0100
Message-ID: <20161206152826.GN1984@nanopsycho>
References: <1481037486-27195-1-git-send-email-ogerlitz@mellanox.com>
 <1481037486-27195-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33568 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752779AbcLFP2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:28:52 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so22104646wmu.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 07:28:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481037486-27195-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 04:18:05PM CET, ogerlitz@mellanox.com wrote:
>Add UAPI to provide set of flags for matching, where the flags
>provided from user-space are mapped to flow-dissector flags.
>
>The 1st flag allows to match on whether the packet is an
>IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Reviewed-by: Paul Blakey <paulb@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
