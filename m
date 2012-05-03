From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] tcp: early retransmit
Date: Wed, 02 May 2012 20:56:32 -0400 (EDT)
Message-ID: <20120502.205632.1243678429154477100.davem@davemloft.net>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
	<1336001404-21879-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, ncardwell@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab2ECA4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:56:43 -0400
In-Reply-To: <1336001404-21879-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  2 May 2012 16:30:03 -0700

> This patch implements RFC 5827 early retransmit (ER) for TCP.
> It reduces DUPACK threshold (dupthresh) if outstanding packets are
> less than 4 to recover losses by fast recovery instead of timeout.
 ...
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
