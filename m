From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6: move IPV6_TCLASS_SHIFT into ipv6.h
 and define a helper
Date: Wed, 15 Jan 2014 15:54:07 -0800 (PST)
Message-ID: <20140115.155407.1533278236811168607.davem@davemloft.net>
References: <1389776610-19703-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaAOXyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:54:08 -0500
In-Reply-To: <1389776610-19703-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 15 Jan 2014 17:03:30 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Two places defined IPV6_TCLASS_SHIFT, so we should move it into ipv6.h,
> and use this macro as possible. And define ip6_tclass helper to return
> tclass
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thank you.
