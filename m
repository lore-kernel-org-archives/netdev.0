From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6 Use get_hash_from_flowi6 for rt6 hash
Date: Wed, 23 Sep 2015 14:21:38 -0700 (PDT)
Message-ID: <20150923.142138.873048869450376623.davem@davemloft.net>
References: <1443042815-3458631-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, pch@ordbogen.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109AbbIWVVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:21:41 -0400
In-Reply-To: <1443042815-3458631-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 23 Sep 2015 14:13:35 -0700

> In rt6_info_hash_nhsfn replace the custom hashing over flowi6 that is
> using xor with a call to common function get_hash_from_flowi6.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks.
