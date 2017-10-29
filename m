From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/4] net: sched: block callbacks follow-up
Date: Sun, 29 Oct 2017 18:36:32 +0900 (KST)
Message-ID: <20171029.183632.1515928020513719137.davem@davemloft.net>
References: <20171025143500.28973-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdJ2Jgp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 05:36:45 -0400
In-Reply-To: <20171025143500.28973-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 25 Oct 2017 16:34:56 +0200

> This patchset does a bit of cleanup of leftovers after block callbacks
> patchset. The main part is patch 2, which restores the original handling
> of tc offload feature flag.

Jiri, this series does not apply cleanly to net-next.

Also, you should really work out the block offload semantics
with Jakub, continuing the discussion of patch #2.

Thanks.
