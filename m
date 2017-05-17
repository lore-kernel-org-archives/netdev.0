From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 05/10] net: sched: move TC_H_MAJ macro call
 into tcf_auto_prio
Date: Wed, 17 May 2017 08:14:00 -0400
Message-ID: <6a6b928a-8faa-a9fe-2e81-038a0a3bbf0a@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-6-jiri@resnulli.us>
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
Received: from mail-it0-f65.google.com ([209.85.214.65]:33958 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753778AbdEQMOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:14:03 -0400
Received: by mail-it0-f65.google.com with SMTP id d68so1294766ita.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:14:03 -0700 (PDT)
In-Reply-To: <20170517090803.4461-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:07 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Call the helper from the function rather than to always adjust the
> return value of the function.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
