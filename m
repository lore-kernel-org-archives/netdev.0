From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] irda: GFP_ATOMIC cleanups
Date: Mon, 08 Apr 2013 12:10:01 -0400 (EDT)
Message-ID: <20130408.121001.1972542274031976032.davem@davemloft.net>
References: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934098Ab3DHQKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:10:03 -0400
In-Reply-To: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Fri,  5 Apr 2013 22:41:26 +0200

> Hi Samuel, Dave,
> 
> this small series changes some obvious misusages of GFP_ATOMIC in the
> irda code.
> 
> Please apply -- probably to net-next!

Both applied, thanks.
