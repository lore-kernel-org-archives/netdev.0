From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 14:48:18 +0100
Message-ID: <20070416134818.GA15915@infradead.org>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59667 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbXDPNsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 09:48:20 -0400
Content-Disposition: inline
In-Reply-To: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It would be easier if you sent all bits in a single patch, it's
one logical change after all, and a rather small one aswell.

