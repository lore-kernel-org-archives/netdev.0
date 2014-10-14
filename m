From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove aca_lock spinlock from struct ifacaddr6
Date: Tue, 14 Oct 2014 13:16:03 -0400 (EDT)
Message-ID: <20141014.131603.663078350161195232.davem@davemloft.net>
References: <1413003814-14216-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371AbaJNRQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 13:16:07 -0400
In-Reply-To: <1413003814-14216-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat, 11 Oct 2014 13:03:34 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> no user uses this lock.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
