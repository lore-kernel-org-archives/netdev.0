From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4vf: don't offload Rx checksums for
 IPv6 fragments
Date: Thu, 15 Sep 2016 19:38:12 -0400 (EDT)
Message-ID: <20160915.193812.625337067539560540.davem@davemloft.net>
References: <1473754164-14478-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756530AbcIOXiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:38:15 -0400
In-Reply-To: <1473754164-14478-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 13 Sep 2016 13:39:24 +0530

> The checksum provided by the device doesn't include the L3 headers,
> as IPv6 expects
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
> V2: Fixed compilation issue reported by kbuild bot

Applied.
