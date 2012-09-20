From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fixed a TFO server bug that crashed kernel by raw
 sockets
Date: Thu, 20 Sep 2012 17:13:14 -0400 (EDT)
Message-ID: <20120920.171314.539416435511236353.davem@davemloft.net>
References: <1348011351-13882-1-git-send-email-hkchu@google.com>
	<4380003.jOHRfqhomY@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	edumazet@google.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab2ITVNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 17:13:16 -0400
In-Reply-To: <4380003.jOHRfqhomY@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed, 19 Sep 2012 02:19:23 +0200

> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Wed, 19 Sep 2012 02:06:53 +0200
> Subject: [PATCH] Don't add TCP-code in inet_sock_destruct
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thanks.
