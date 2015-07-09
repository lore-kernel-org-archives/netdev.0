From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Fix check to use new User Doorbell
 mechanism
Date: Thu, 09 Jul 2015 00:02:16 -0700 (PDT)
Message-ID: <20150709.000216.381351918681567834.davem@davemloft.net>
References: <1436433946-10735-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbbGIHCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 03:02:16 -0400
In-Reply-To: <1436433946-10735-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  9 Jul 2015 14:55:46 +0530

> If we don't have access to the new User GTS (T5+), use the old doorbell
> mechanism; otherwise use the new BAR2 mechanism.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
