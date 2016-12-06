From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 2/2] net/mlx5e: Offload TC matching on
 packets being IP fragments
Date: Tue, 6 Dec 2016 16:28:45 +0100
Message-ID: <20161206152845.GO1984@nanopsycho>
References: <1481037486-27195-1-git-send-email-ogerlitz@mellanox.com>
 <1481037486-27195-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36046 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753067AbcLFP2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:28:52 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so22136348wma.3
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 07:28:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481037486-27195-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 04:18:06PM CET, ogerlitz@mellanox.com wrote:
>Enable offloading of matching on packets being fragments.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Reviewed-by: Paul Blakey <paulb@mellanox.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
