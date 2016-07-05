From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5: Avoid setting unused var when modifying
 vport node GUID
Date: Tue, 05 Jul 2016 12:13:16 -0700 (PDT)
Message-ID: <20160705.121316.1798687160710211263.davem@davemloft.net>
References: <1467710232-31192-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, noaos@mellanox.com, saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbcGETNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:13:17 -0400
In-Reply-To: <1467710232-31192-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  5 Jul 2016 12:17:12 +0300

> GCC complains on unused-but-set-variable, clean this up.
> 
> Fixes: 23898c763f4a ('net/mlx5: E-Switch, Modify node guid on vf set MAC')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
