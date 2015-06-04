From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: micrel: use time_after_eq
Date: Wed, 03 Jun 2015 19:39:11 -0700 (PDT)
Message-ID: <20150603.193911.2150548377119751337.davem@davemloft.net>
References: <1433248552-7994-1-git-send-email-antonio.murdaca@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, akpm@linux-foundation.org,
	antonio.murdaca@gmail.com
To: antoniomurdaca@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbbFDCjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:39:12 -0400
In-Reply-To: <1433248552-7994-1-git-send-email-antonio.murdaca@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Murdaca <antoniomurdaca@gmail.com>
Date: Tue,  2 Jun 2015 14:35:52 +0200

> use the time_after_eq macro for jiffies comparison operation
> 
> Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>

Applied to net-next, thanks.
