From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/4] net: sched: block callbacks follow-up
Date: Thu, 02 Nov 2017 16:12:18 +0900 (KST)
Message-ID: <20171102.161218.1843909398891251556.davem@davemloft.net>
References: <20171101104741.2216-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdKBHM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:12:29 -0400
In-Reply-To: <20171101104741.2216-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  1 Nov 2017 11:47:37 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset does a bit of cleanup of leftovers after block callbacks
> patchset. The main part is patch 2, which restores the original handling
> of tc offload feature flag.
> 
> ---
> v1->v2:
> - rebased on top of current net-next (bnxt changes)

Series applied, thanks Jiri.
