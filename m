From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/dsa/dsa.c: increment chip_index during of_node
 handling on dsa_of_probe()
Date: Fri, 16 May 2014 16:56:53 -0400 (EDT)
Message-ID: <20140516.165653.1225889174307693569.davem@davemloft.net>
References: <1400214104-27699-1-git-send-email-fg@emlix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fg@emlix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbaEPU4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:56:55 -0400
In-Reply-To: <1400214104-27699-1-git-send-email-fg@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Godehardt <fg@emlix.com>
Date: Fri, 16 May 2014 06:21:44 +0200

> Adding more than one chip on device-tree currently causes the probing 
> routine to always use the first chips data pointer.
> 
> Signed-off-by: Fabian Godehardt <fg@emlix.com>

Applied, thank you.
