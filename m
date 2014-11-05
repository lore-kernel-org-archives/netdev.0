From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/linux/socket.h: Fix comment
Date: Wed, 05 Nov 2014 15:52:55 -0500 (EST)
Message-ID: <20141105.155255.85151784742273625.davem@davemloft.net>
References: <1415220267-20044-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaKEUw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:52:57 -0500
In-Reply-To: <1415220267-20044-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed,  5 Nov 2014 21:44:27 +0100

> File descriptors are always closed on exit :-)
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thanks.
