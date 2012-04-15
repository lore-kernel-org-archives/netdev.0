From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cleanup unsigned to unsigned int
Date: Sun, 15 Apr 2012 12:45:37 -0400 (EDT)
Message-ID: <20120415.124537.385779887277186357.davem@davemloft.net>
References: <1334505486.28012.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab2DOQpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 12:45:39 -0400
In-Reply-To: <1334505486.28012.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Apr 2012 17:58:06 +0200

> Use of "unsigned int" is preferred to bare "unsigned" in net tree.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
