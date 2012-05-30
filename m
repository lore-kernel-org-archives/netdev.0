From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix oops in L2TP IP sockets for connect()
 AF_UNSPEC case
Date: Wed, 30 May 2012 05:05:32 -0400 (EDT)
Message-ID: <20120530.050532.2246390428654877169.davem@davemloft.net>
References: <1338298242-22261-1-git-send-email-jchapman@katalix.com>
	<20120529.172008.875375243438479060.davem@davemloft.net>
	<4FC5E022.6020609@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, levinsasha928@gmail.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372Ab2E3JFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 05:05:38 -0400
In-Reply-To: <4FC5E022.6020609@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 30 May 2012 09:53:54 +0100

> The patch doesn't apply to stable due to recent l2tp_ip changes (IPv6
> support) already merged. I'll spin a version for -stable.

That would be helpful, please do.
