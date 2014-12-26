From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: incorrect use of init_completion fixup
Date: Fri, 26 Dec 2014 17:08:11 -0500 (EST)
Message-ID: <20141226.170811.464811931780644413.davem@davemloft.net>
References: <1419356870-22710-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: der.herr@hofr.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaLZWIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 17:08:14 -0500
In-Reply-To: <1419356870-22710-1-git-send-email-der.herr@hofr.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Tue, 23 Dec 2014 18:47:50 +0100

> The second init_completion call should be a reinit_completion here.
> 
> patch is against 3.18.0 linux-next
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>

Applied, thanks.
