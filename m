From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 3/6] sched: push TC filter protocol creation into
 a separate function
Date: Thu, 9 Feb 2017 13:23:26 -0500
Message-ID: <524375aa-6d5c-7b30-b700-d19c7cdeda9d@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35732 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754041AbdBIScj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:32:39 -0500
Received: by mail-io0-f195.google.com with SMTP id m98so2948523iod.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:32:34 -0800 (PST)
In-Reply-To: <1486647540-14656-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Make the long function tc_ctl_tfilter a little bit shorter and easier to
> read. Also make the creation of filter proto symmetric to destruction.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
