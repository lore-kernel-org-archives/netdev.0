From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 01/20] net: sched: sch_atm: use
 Qdisc_class_common structure
Date: Sun, 30 Jul 2017 15:04:45 -0400
Message-ID: <c01d32fd-03da-5148-54c7-3830d97153d1@mojatatu.com>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34831 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754308AbdG3TEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:04:51 -0400
Received: by mail-io0-f194.google.com with SMTP id f1so17822672ioj.2
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:04:51 -0700 (PDT)
In-Reply-To: <20170728144042.6380-2-jiri@resnulli.us>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 10:40 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Even if it is only for classid now, use this common struct a be aligned
> with the rest of the classful qdiscs.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Looks good to me.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
