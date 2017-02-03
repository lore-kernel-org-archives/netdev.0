From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH 1/3] net/sched: act_ife: Unexport ife_tlv_meta_encode
Date: Fri, 03 Feb 2017 08:30:51 -0500
Message-ID: <85o9yjo0z8.fsf@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
        <1485955803-65065-2-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        eladr@mellanox.com, jiri@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36776 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbdBCNaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:30:55 -0500
Received: by mail-io0-f195.google.com with SMTP id q20so2189299ioi.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:30:55 -0800 (PST)
In-Reply-To: <1485955803-65065-2-git-send-email-yotamg@mellanox.com> (Yotam
        Gigi's message of "Wed, 1 Feb 2017 15:30:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yotam Gigi <yotamg@mellanox.com> writes:

> As the function ife_tlv_meta_encode is not used by any other module,
> unexport it and make it static for the act_ife module.
>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>

-- 
Roman Mashak
