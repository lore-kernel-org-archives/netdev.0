From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 4/6] sched: move err set right before goto errout
 in tc_ctl_tfilter
Date: Thu, 9 Feb 2017 13:25:34 -0500
Message-ID: <6eb218ab-5e4a-f305-92a0-1baab98666c0@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36222 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752926AbdBIScA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:32:00 -0500
Received: by mail-io0-f171.google.com with SMTP id j13so24689935iod.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:31:50 -0800 (PST)
In-Reply-To: <1486647540-14656-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> This makes the reader to know right away what is the error value.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>


I think you meant "makes it easier to read"? Thats how i see
this change.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
