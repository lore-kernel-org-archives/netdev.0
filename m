From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] bql: Fix POSDIFF() to integer overflow aware.
Date: Thu, 31 May 2012 18:19:49 -0400 (EDT)
Message-ID: <20120531.181949.2071741410069390941.davem@davemloft.net>
References: <20120531072439.6c634a0b.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757289Ab2EaWTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 18:19:54 -0400
In-Reply-To: <20120531072439.6c634a0b.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 31 May 2012 07:24:39 +0900

> POSDIFF() fails to take into account integer overflow case.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable.
