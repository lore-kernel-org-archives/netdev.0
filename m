From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] ila: Precompute checksums
Date: Mon, 24 Aug 2015 10:39:02 -0700 (PDT)
Message-ID: <20150824.103902.1554046250835262292.davem@davemloft.net>
References: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbHXRjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:39:03 -0400
In-Reply-To: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 24 Aug 2015 09:45:40 -0700

> This patch set:
>  - Adds argument ot LWT build_state that holds a pointer to the fib
>    configuration being applied to the new route
>  - Adds support in ILA to precompute checksum difference for
>    performance optimization
> 
> v2:
>  - Move return argument in build_state to end of arguments
> 
> v3:
>  - Update the signature for ip6_tun_build_state()

Applied, thanks.
