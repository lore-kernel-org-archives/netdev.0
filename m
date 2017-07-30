From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 03/20] net: sched: change names of action number
 helpers to be aligned with the rest
Date: Sun, 30 Jul 2017 15:46:21 -0400
Message-ID: <4ddf5e09-4051-c8fa-df9e-725e2ccacba4@mojatatu.com>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36013 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754529AbdG3TqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:46:24 -0400
Received: by mail-it0-f68.google.com with SMTP id r9so17645874ita.3
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:46:24 -0700 (PDT)
In-Reply-To: <20170728144042.6380-4-jiri@resnulli.us>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 10:40 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> The rest of the helpers are named tcf_exts_*, so change the name of
> the action number helpers to be aligned. While at it, change to inline
> functions.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Looks reasonable.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
