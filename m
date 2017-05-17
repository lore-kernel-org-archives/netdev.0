From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 04/10] net: sched: replace nprio by a bool to
 make the function more readable
Date: Wed, 17 May 2017 08:13:27 -0400
Message-ID: <b7135975-a1f4-ee06-2824-726a0b92a65a@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-5-jiri@resnulli.us>
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
Received: from mail-io0-f196.google.com ([209.85.223.196]:33245 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdEQMNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:13:30 -0400
Received: by mail-io0-f196.google.com with SMTP id m4so1227351ioe.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:13:30 -0700 (PDT)
In-Reply-To: <20170517090803.4461-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:07 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> The use of "nprio" variable in tc_ctl_tfilter is a bit cryptic and makes
> a reader wonder what is going on for a while. So help him to understand
> this priority allocation dance a litte bit better.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
