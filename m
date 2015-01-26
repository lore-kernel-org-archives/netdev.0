From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fixes cxgb4_inet6addr_notifier
 unregister call
Date: Mon, 26 Jan 2015 14:46:02 -0800 (PST)
Message-ID: <20150126.144602.1994549620721708994.davem@davemloft.net>
References: <1421854072-6427-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbAZWqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:46:03 -0500
In-Reply-To: <1421854072-6427-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 21 Jan 2015 20:57:52 +0530

> commit b5a02f503caa0837 ("cxgb4 : Update ipv6 address handling api") introduced
> a regression where unregister cxgb4_inet6addr_notifier wasn't getting called
> during module_exit.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
