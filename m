From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netvsc: fix typo on statistics
Date: Fri, 17 Feb 2017 15:08:52 -0500 (EST)
Message-ID: <20170217.150852.1713216306408468161.davem@davemloft.net>
References: <20170217193620.12175-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sixaio@microsoft.com, sixiao@microsoft.com,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbdBQUIy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:08:54 -0500
In-Reply-To: <20170217193620.12175-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 17 Feb 2017 11:36:20 -0800

> From: Simon Xiao <sixaio@microsoft.com>
> 
> Return the correct tx_errors stats in netvsc.
> 
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks Stephen.
