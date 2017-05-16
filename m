From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/10] net: sched: introduce multichain
 support for filters
Date: Tue, 16 May 2017 18:23:46 +0200
Message-ID: <20170516162345.GN1939@nanopsycho.orion>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170516.122021.1415036093574332123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33249 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdEPQXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:23:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id y10so39518091wmh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 09:23:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170516.122021.1415036093574332123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 06:20:21PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 15 May 2017 10:38:47 +0200
>
>> This patchset contains two major patches:
>> 8/10 - This patch introduces the support for having multiple
>>        chains of filters.
>> 10/10 - This patch adds new control action to allow going to specified chain
>> 
>> The rest of the patches are smaller or bigger depencies of those 2.
>> Please see individual patch descriptions for details.
>
>I'm expecting at least some adjustments to the tests in the final
>patch based upon your discussions with Daniel, and thus another
>spin of this series.

Will send in a jiff. Thanks
