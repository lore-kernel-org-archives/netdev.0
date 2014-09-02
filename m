From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: arc: remove unused dev
Date: Tue, 02 Sep 2014 13:53:15 -0700 (PDT)
Message-ID: <20140902.135315.1585058264955092847.davem@davemloft.net>
References: <001a01cfc64f$f4421040$dcc630c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romain.perier@gmail.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaIBUxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:53:16 -0400
In-Reply-To: <001a01cfc64f$f4421040$dcc630c0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 02 Sep 2014 10:48:11 +0900

> Remove unused 'dev' variable from arc_emac_remove(), since it's
> not being used any more.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied, thanks.
