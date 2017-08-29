From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] mlx4 misc patches
Date: Tue, 29 Aug 2017 14:58:51 -0700 (PDT)
Message-ID: <20170829.145851.2083650943174871795.davem@davemloft.net>
References: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbdH2V6w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:58:52 -0400
In-Reply-To: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 28 Aug 2017 16:38:19 +0300

> This patchset contains misc patches from the team
> to the mlx4 Core and Eth drivers.
> 
> Patch 1 by Eran replaces large static allocations by dynamic ones.
> Patch 2 by Leon makes an explicit conversion and solves a smatch warning.
> In patch 3 I fix a misplaced brackets of the sizeof operation.
> Patch 4 by Moshe adds the ability to inform the FW regarding user mac updates.
> 
> Series generated against net-next commit:
> 901c5d2fbfcd ARM: dts: rk3228-evb: Fix the compiling error

Series applied, thanks.
