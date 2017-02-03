From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] net/sched: act_ife: Unexport ife_tlv_meta_encode
Date: Fri, 3 Feb 2017 08:05:39 -0500
Message-ID: <c7e1f54f-3af3-91b6-397c-b1cf06eebe14@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
 <1485955803-65065-2-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotamg@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, mrv@mojatatu.com, eladr@mellanox.com,
        jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36536 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdBCNFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:05:42 -0500
Received: by mail-it0-f66.google.com with SMTP id f200so1618876itf.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:05:41 -0800 (PST)
In-Reply-To: <1485955803-65065-2-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-01 08:30 AM, Yotam Gigi wrote:
> As the function ife_tlv_meta_encode is not used by any other module,
> unexport it and make it static for the act_ife module.
>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
