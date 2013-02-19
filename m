From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: ipv4: fix waring -Wunused-variable
Date: Tue, 19 Feb 2013 13:19:33 -0500 (EST)
Message-ID: <20130219.131933.489737861222137205.davem@davemloft.net>
References: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1361270592-19492-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858Ab3BSSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:19:34 -0500
In-Reply-To: <1361270592-19492-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 19 Feb 2013 18:43:12 +0800

> the vars ip_rt_gc_timeout is used only when
> CONFIG_SYSCTL is selected.
> 
> move these vars into CONFIG_SYSCTL.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
