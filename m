From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 1/6] sched: rename tcf_destroy to
 tcf_destroy_proto
Date: Thu, 9 Feb 2017 13:20:58 -0500
Message-ID: <02058d20-aee3-6c70-61ce-cb80ae712e71@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35079 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932087AbdBISWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:22:21 -0500
Received: by mail-io0-f196.google.com with SMTP id m98so2892132iod.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:21:00 -0800 (PST)
In-Reply-To: <1486647540-14656-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> This function destroys TC filter protocol, not TC filter. So name it
> accordingly.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
