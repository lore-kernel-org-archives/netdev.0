From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove redundant assignment
Date: Mon, 23 Jul 2012 13:09:39 -0700 (PDT)
Message-ID: <20120723.130939.1076493763590148118.davem@davemloft.net>
References: <1343052681.4600.5.camel@monkey32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847Ab2GWUJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:09:40 -0400
In-Reply-To: <1343052681.4600.5.camel@monkey32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Mon, 23 Jul 2012 22:11:21 +0800

> It is redundant to set no_addr and accept_local to 0 and then set them
> with other values just after that.
> 
> Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>

Applied, thanks.
