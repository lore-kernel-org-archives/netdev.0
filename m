From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH 3/3] net/sched: act_ife: Change to use ife module
Date: Fri, 03 Feb 2017 08:31:32 -0500
Message-ID: <85fujvo0y3.fsf@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
        <1485955803-65065-4-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        eladr@mellanox.com, jiri@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35944 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752521AbdBCNbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:31:36 -0500
Received: by mail-it0-f41.google.com with SMTP id c7so11226694itd.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:31:36 -0800 (PST)
In-Reply-To: <1485955803-65065-4-git-send-email-yotamg@mellanox.com> (Yotam
        Gigi's message of "Wed, 1 Feb 2017 15:30:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yotam Gigi <yotamg@mellanox.com> writes:

> Use the encode/decode functionality from the ife module instead of using
> implementation inside the act_ife.
>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>

-- 
Roman Mashak
