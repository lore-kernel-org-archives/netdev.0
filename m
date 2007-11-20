From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/core/request_sock.c: remove unused exports
Date: Mon, 19 Nov 2007 22:46:19 -0800 (PST)
Message-ID: <20071119.224619.85100019.davem@davemloft.net>
References: <20071117115848.GB4250@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40565
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758338AbXKTGqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:46:19 -0500
In-Reply-To: <20071117115848.GB4250@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sat, 17 Nov 2007 12:58:48 +0100

> This patch removes the following unused EXPORT_SYMBOL's:
> - reqsk_queue_alloc
> - __reqsk_queue_destroy
> - reqsk_queue_destroy
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied to net-2.6.25, thanks Adrian.
