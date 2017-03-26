From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_kvdl: Cosmetic kvdl allocator
 API change
Date: Sat, 25 Mar 2017 19:56:27 -0700 (PDT)
Message-ID: <20170325.195627.1031680764200229260.davem@davemloft.net>
References: <1490426902-1981-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdCZDEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 23:04:16 -0400
In-Reply-To: <1490426902-1981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 25 Mar 2017 08:28:22 +0100

> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Currently the return allocated index and err value are multiplexed.
> This patch changes the API to decouple the ret value from the allocated
> index.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
