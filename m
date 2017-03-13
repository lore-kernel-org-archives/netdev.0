From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/9] mlxsw: Add support for TC flower offload
 statistics
Date: Sun, 12 Mar 2017 23:50:30 -0700 (PDT)
Message-ID: <20170312.235030.511958998680986815.davem@davemloft.net>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdCMGub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:50:31 -0400
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 11 Mar 2017 09:42:50 +0100

> Arkadi says:
> This patchset adds support for retrieving TC flower statistics for
> offloaded rules, which includes packets count, bytes count and last used
> time stamp. Currently The statistics are gathered on a per-rule basis.
> 
> This patchset also includes generic allocator for counters.

Series applied, thank you.
