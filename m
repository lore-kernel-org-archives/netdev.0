From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: net_device flags is an unsigned int
Date: Thu, 01 Dec 2011 12:39:35 -0500 (EST)
Message-ID: <20111201.123935.1114224762183791317.davem@davemloft.net>
References: <1322725346.2577.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1LARjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 12:39:41 -0500
In-Reply-To: <1322725346.2577.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 08:42:26 +0100

> commit b00055aacdb ([NET] core: add RFC2863 operstate) changed
> net_device flags from unsigned short to unsigned int.
> 
> Some core functions still assume its an unsigned short.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
