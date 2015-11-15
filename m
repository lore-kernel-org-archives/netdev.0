From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ipv6: Fixes for pmtu update and DST_NOCACHE
 route
Date: Sun, 15 Nov 2015 17:18:38 -0500 (EST)
Message-ID: <20151115.171838.1737045138252643160.davem@davemloft.net>
References: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbbKOWSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 17:18:40 -0500
In-Reply-To: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 11 Nov 2015 11:51:05 -0800

> This patchset fixes:
> 1. An oops during IPv6 pmtu update on a IPv4 GRE running
>    in an IPSec setup
> 2. Misc fixes on DST_NOCACHE route

Series applied and queued up for -stable, thanks.
