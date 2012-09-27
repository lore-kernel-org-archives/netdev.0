From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Remove unused parameter from tcp_v4_save_options
Date: Thu, 27 Sep 2012 19:20:47 -0400 (EDT)
Message-ID: <20120927.192047.1816625684021822646.davem@davemloft.net>
References: <1348696749-29999-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I0XUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:20:48 -0400
In-Reply-To: <1348696749-29999-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed, 26 Sep 2012 23:59:09 +0200

> struct sock *sk is not used inside tcp_v4_save_options. Thus it can be
> removed.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thanks.
