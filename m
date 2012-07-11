From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge/s2io: remove dead URLs
Date: Tue, 10 Jul 2012 23:18:32 -0700 (PDT)
Message-ID: <20120710.231832.391247031231469078.davem@davemloft.net>
References: <1341878877-10507-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab2GKGSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:18:33 -0400
In-Reply-To: <1341878877-10507-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon,  9 Jul 2012 17:07:57 -0700

> URLs to neterion.com and s2io.com no longer resolve.  Remove all references to
> these URLs in the driver source and documentation.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied, but I had to fix:

> -7. Support 
> +6. Support 
             ^^

that trailing whitespace.
