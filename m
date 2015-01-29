From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gianfar: remove the unneeded check of
 disabled device
Date: Thu, 29 Jan 2015 14:51:42 -0800 (PST)
Message-ID: <20150129.145142.1078710578535354028.davem@davemloft.net>
References: <1422446808-16460-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: haokexin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbA2Wvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:51:43 -0500
In-Reply-To: <1422446808-16460-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>
Date: Wed, 28 Jan 2015 20:06:48 +0800

> Since commit cd1e65044d44 ("of/device: Don't register disabled
> devices"), the disabled device will not be registered at all. So we
> don't need to do the check again in the platform device driver.
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>

Applied, thanks.
