From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2/net-next] tc: add support for TRAP action
Date: Thu, 8 Jun 2017 20:41:18 +0200
Message-ID: <20170608184118.GH2238@nanopsycho>
References: <20170605143832.7025-1-jiri@resnulli.us>
 <20170605143945.7094-1-jiri@resnulli.us>
 <20170608192612.6a9c175a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35818 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdFHSlV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:41:21 -0400
Received: by mail-wr0-f173.google.com with SMTP id q97so22037367wrb.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 11:41:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170608192612.6a9c175a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 08, 2017 at 07:26:12PM CEST, jbenc@redhat.com wrote:
>On Mon,  5 Jun 2017 16:39:45 +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/pkt_cls.h | 5 +++++
>>  tc/tc_util.c            | 3 +++
>>  2 files changed, 8 insertions(+)
>
>No documentation again. Please add the description of the new action to
>a man page.

Will do. It's on my todo list.
