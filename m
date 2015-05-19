From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: remove unused function prototype
Date: Tue, 19 May 2015 16:54:50 -0400 (EDT)
Message-ID: <20150519.165450.1989356177228527748.davem@davemloft.net>
References: <1432064507-925-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbESUyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:54:52 -0400
In-Reply-To: <1432064507-925-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Tue, 19 May 2015 12:41:47 -0700

> ip_do_nat() function was removed prior to kernel 3.4. Remove the
> unnecessary function prototype as well.
> 
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied, thank you.
