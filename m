From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net/ipv4/ip_vti.c: Fix __rcu warnings detected by
 sparse.
Date: Mon, 23 Jul 2012 13:09:45 -0700 (PDT)
Message-ID: <20120723.130945.1488521239475360508.davem@davemloft.net>
References: <20120723175204.GA2762@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911Ab2GWUJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:09:46 -0400
In-Reply-To: <20120723175204.GA2762@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Mon, 23 Jul 2012 10:52:04 -0700

> 
> 
> With CONFIG_SPARSE_RCU_POINTER=y sparse identified references which did not
> specificy __rcu in ip_vti.c
> 
> Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>

Applied.
