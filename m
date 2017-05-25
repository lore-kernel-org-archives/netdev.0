From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/packet: remove unused parameter in
 prb_curr_blk_in_use().
Date: Thu, 25 May 2017 13:19:56 -0400 (EDT)
Message-ID: <20170525.131956.1789298514174578181.davem@davemloft.net>
References: <1495640051-39181-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031883AbdEYRT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:19:58 -0400
In-Reply-To: <1495640051-39181-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Wed, 24 May 2017 18:34:11 +0300

> This patch removes unused parameter from prb_curr_blk_in_use() method
> in net/packet/af_packet.c.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied.
