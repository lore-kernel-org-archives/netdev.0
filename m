From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/10] net: sched: introduce multichain
 support for filters
Date: Tue, 16 May 2017 12:20:21 -0400 (EDT)
Message-ID: <20170516.122021.1415036093574332123.davem@davemloft.net>
References: <20170515083857.3615-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751909AbdEPQUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:20:25 -0400
In-Reply-To: <20170515083857.3615-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 15 May 2017 10:38:47 +0200

> This patchset contains two major patches:
> 8/10 - This patch introduces the support for having multiple
>        chains of filters.
> 10/10 - This patch adds new control action to allow going to specified chain
> 
> The rest of the patches are smaller or bigger depencies of those 2.
> Please see individual patch descriptions for details.

I'm expecting at least some adjustments to the tests in the final
patch based upon your discussions with Daniel, and thus another
spin of this series.
