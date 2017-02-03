From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 3/3] net/sched: act_ife: Change to use ife module
Date: Fri, 3 Feb 2017 08:08:30 -0500
Message-ID: <92023d20-7527-1329-2ee1-9cf96c9bf9a2@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
 <1485955803-65065-4-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotamg@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, mrv@mojatatu.com, eladr@mellanox.com,
        jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35107 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbdBCNIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:08:32 -0500
Received: by mail-io0-f172.google.com with SMTP id j18so16843659ioe.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:08:32 -0800 (PST)
In-Reply-To: <1485955803-65065-4-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-01 08:30 AM, Yotam Gigi wrote:
> Use the encode/decode functionality from the ife module instead of using
> implementation inside the act_ife.
>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
