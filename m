From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 07/10] net: sched: push chain dump to a
 separate function
Date: Wed, 17 May 2017 08:19:57 -0400
Message-ID: <29988d6f-a1b0-50f1-5aba-575d0f880805@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34491 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdEQMUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:20:00 -0400
Received: by mail-it0-f66.google.com with SMTP id d68so1308934ita.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:19:59 -0700 (PDT)
In-Reply-To: <20170517090803.4461-8-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:08 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Since there will be multiple chains to dump, push chain dumping code to
> a separate function.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
