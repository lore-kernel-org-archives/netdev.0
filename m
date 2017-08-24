From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: spectrum: Introduce multichain TC
 offload
Date: Wed, 23 Aug 2017 20:45:32 -0700 (PDT)
Message-ID: <20170823.204532.1960077179362593735.davem@davemloft.net>
References: <20170823080652.14847-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdHXDpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:45:33 -0400
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 23 Aug 2017 10:06:52 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset introduces offloading of rules added to chain with
> non-zero index, which was previously forbidden. Also, goto_chain
> termination action is offloaded allowing to jump to processing
> of desired chain.

Series applied, thanks Jiri.
