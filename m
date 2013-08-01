From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-net v2] tipc: fix oops when creating server socket fails
Date: Thu, 01 Aug 2013 15:55:07 -0700 (PDT)
Message-ID: <20130801.155507.196569560728305996.davem@davemloft.net>
References: <20130731.152020.219915207900769828.davem@davemloft.net>
	<1375360158-24753-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ying.xue@windriver.com,
	jon.maloy@ericsson.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533Ab3HAWzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:55:08 -0400
In-Reply-To: <1375360158-24753-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 1 Aug 2013 08:29:18 -0400

> From: Ying Xue <ying.xue@windriver.com>
> 
> When creation of TIPC internal server socket fails,
> we get an oops with the following dump:
 ...
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
