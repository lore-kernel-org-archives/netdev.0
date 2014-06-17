From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: In the testptp utility, use clock_adjtime from
 glibc when available
Date: Mon, 16 Jun 2014 21:32:43 -0700 (PDT)
Message-ID: <20140616.213243.1726778958774333018.davem@davemloft.net>
References: <1402922805-3664-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbaFQEco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:32:44 -0400
In-Reply-To: <1402922805-3664-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Mon, 16 Jun 2014 14:46:45 +0200

> clock_adjtime was included in glibc 2.14. _GNU_SOURCE must be defined
> to make it available.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied, thank you.
