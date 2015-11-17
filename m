From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: Use PAGE_ALIGNED macro
Date: Tue, 17 Nov 2015 15:26:34 -0500 (EST)
Message-ID: <20151117.152634.1635376036003233940.davem@davemloft.net>
References: <1447753221-11998-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbbKQU0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:26:35 -0500
In-Reply-To: <1447753221-11998-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Nov 2015 10:40:21 +0100

> Use PAGE_ALIGNED(...) instead of open-coding it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
