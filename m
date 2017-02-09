From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/6] sched: move tcf_proto_destroy and
 tcf_destroy_chain helpers into cls_api
Date: Thu, 9 Feb 2017 13:21:43 -0500
Message-ID: <afe3d61f-5cc6-e51d-eb73-c42b00ad51ef@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34593 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdBISbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:31:34 -0500
Received: by mail-io0-f193.google.com with SMTP id c80so2948951iod.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:30:40 -0800 (PST)
In-Reply-To: <1486647540-14656-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Creation is done in this file, move destruction to be at the same place.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
