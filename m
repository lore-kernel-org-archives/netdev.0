From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] tcp: syncookies: mark cookie_secret read_mostly
Date: Wed, 27 Aug 2014 16:31:17 -0700 (PDT)
Message-ID: <20140827.163117.2184756713039734082.davem@davemloft.net>
References: <1409050553-21945-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965345AbaH0XbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:31:18 -0400
In-Reply-To: <1409050553-21945-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 26 Aug 2014 12:55:53 +0200

> only written once.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
