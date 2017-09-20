From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net] net_sched: remove cls_flower idr on failure
Date: Wed, 20 Sep 2017 18:40:54 +0200
Message-ID: <20170920164054.GC2281@nanopsycho>
References: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Mi <chrism@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:54053 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751572AbdITQk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:40:56 -0400
Received: by mail-wr0-f169.google.com with SMTP id l22so2668352wrc.10
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:40:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 20, 2017 at 06:18:45PM CEST, xiyou.wangcong@gmail.com wrote:
>Fixes: c15ab236d69d ("net/sched: Change cls_flower to use IDR")
>Cc: Chris Mi <chrism@mellanox.com>
>Cc: Jiri Pirko <jiri@mellanox.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks fine.
Acked-by: Jiri Pirko <jiri@mellanox.com>
