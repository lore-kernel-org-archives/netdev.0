From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] drivers: net: xgene-v2: Extend ethtool
 statistics
Date: Tue, 18 Apr 2017 15:55:24 -0400 (EDT)
Message-ID: <20170418.155524.509380512589251718.davem@davemloft.net>
References: <1492472875-32385-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932756AbdDRTz0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:55:26 -0400
In-Reply-To: <1492472875-32385-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 17 Apr 2017 16:47:55 -0700

> This patch adds extended statistics reporting to ethtool.
> 
> In summary, this patch,
> 
>    - adds ethtool.h with the statistics register definitions
>    - adds 'struct xge_gstrings_extd_stats' to gather extended stats
>    - modifies xge_get_strings(), get_sset_count() and
>      get_ethtool_stats() accordingly
>    - moves 'struct xge_gstrings_stats' to ethtool.h
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Applied, thanks.
