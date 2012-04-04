From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Driver: Atm: Remove 'break' after 'return' statement.
Date: Wed, 04 Apr 2012 18:07:52 -0400 (EDT)
Message-ID: <20120404.180752.1993156189941150780.davem@davemloft.net>
References: <1333453638-6235-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab2DDWKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:10:04 -0400
In-Reply-To: <1333453638-6235-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: santosh nayak <santoshprasadnayak@gmail.com>
Date: Tue,  3 Apr 2012 17:17:18 +0530

> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> 'break' is unnecessary after 'return' statement.
> Remove all such 'break' as clean up.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>

Applied, thanks.
