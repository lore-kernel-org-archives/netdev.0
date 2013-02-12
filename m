From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] skbuff: create skb_panic() function and
 its wrappers
Date: Mon, 11 Feb 2013 19:15:02 -0500 (EST)
Message-ID: <20130211.191502.1050356000457429462.davem@davemloft.net>
References: <1360625438-13072-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760679Ab3BLAQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 19:16:41 -0500
In-Reply-To: <1360625438-13072-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Mon, 11 Feb 2013 16:30:38 -0700

> Create skb_panic() function in lieu of both skb_over_panic() and
> skb_under_panic() so that code duplication would be avoided. Update type
> and variable name where necessary.
> 
> Jiri Pirko suggested using wrappers so that we would be able to keep the
> fruits of the original code.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied, thanks.
