From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 01/10] net: sched: move tc_classify function
 to cls_api.c
Date: Wed, 17 May 2017 08:11:19 -0400
Message-ID: <6a4d3e1b-5616-c418-4131-429e985461b1@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-2-jiri@resnulli.us>
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
Received: from mail-it0-f65.google.com ([209.85.214.65]:34320 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdEQML2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:11:28 -0400
Received: by mail-it0-f65.google.com with SMTP id d68so1288157ita.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:11:27 -0700 (PDT)
In-Reply-To: <20170517090803.4461-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:07 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Move tc_classify function to cls_api.c where it belongs, rename it to
> fit the namespace.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
