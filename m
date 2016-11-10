From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc_act: Remove tcf_act macro
Date: Wed, 09 Nov 2016 21:14:25 -0500 (EST)
Message-ID: <20161109.211425.1501381907354399357.davem@davemloft.net>
References: <1478618643-37144-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbcKJCO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:14:29 -0500
In-Reply-To: <1478618643-37144-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Tue,  8 Nov 2016 17:24:03 +0200

> tc_act macro addressed a non existing field, and was not used in the
> kernel source.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied.
