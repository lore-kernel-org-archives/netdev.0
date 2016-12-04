From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] uapi: export tc tunnel key file
Date: Sat, 03 Dec 2016 19:21:31 -0500 (EST)
Message-ID: <20161203.192131.408784466579200963.davem@davemloft.net>
References: <20161202225400.32751-1-sthemmin@microsoft.com>
        <20161202225400.32751-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751591AbcLDA3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:29:37 -0500
In-Reply-To: <20161202225400.32751-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  2 Dec 2016 14:53:58 -0800

> Fixes commit 21609ae32aaf6c6fab0e ("net/sched: Introduce act_tunnel_key")
> The file is necessary for iproute2 headers but was not being
> copied by make install_headers
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

This seems to already be fixed.
