From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] uapi: export tc_skbmod.h
Date: Sat, 03 Dec 2016 19:22:42 -0500 (EST)
Message-ID: <20161203.192242.1375829031436848043.davem@davemloft.net>
References: <20161202225400.32751-1-sthemmin@microsoft.com>
        <20161202225400.32751-3-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcLDA3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:29:37 -0500
In-Reply-To: <20161202225400.32751-3-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  2 Dec 2016 14:53:59 -0800

> Fixes commit 735cffe5d800 ("net_sched: Introduce skbmod action")
> Not used by iproute2 but maybe in future.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
