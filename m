From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] core: simplify the getting percpu of
 flow_cache
Date: Fri, 29 Mar 2013 15:15:13 -0400 (EDT)
Message-ID: <20130329.151513.1257133937847843316.davem@davemloft.net>
References: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756235Ab3C2TPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:15:15 -0400
In-Reply-To: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 28 Mar 2013 20:24:11 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> replace per_cpu with per_cpu_ptr to save conversion between address and pointer
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
