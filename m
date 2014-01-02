From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in sit
Date: Wed, 01 Jan 2014 22:49:32 -0500 (EST)
Message-ID: <20140101.224932.221193077354985616.davem@davemloft.net>
References: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABDte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:49:34 -0500
In-Reply-To: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  2 Jan 2014 08:49:36 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when read/write the 64bit data, the correct lock should be hold.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
