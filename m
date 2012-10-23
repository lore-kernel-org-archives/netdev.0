From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix sparse warnings in
 rt6_info_hash_nhsfn()
Date: Tue, 23 Oct 2012 13:06:21 -0400 (EDT)
Message-ID: <20121023.130621.897912186003916067.davem@davemloft.net>
References: <508653b5.7Vy7DCd02KcUpUab%fengguang.wu@intel.com>
	<1350984906-24672-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256Ab2JWRGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:06:22 -0400
In-Reply-To: <1350984906-24672-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 23 Oct 2012 11:35:06 +0200

> Adding by commit 51ebd3181572 which adds the support of ECMP for IPv6.
> 
> Spotted-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
