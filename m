From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: remove unused variable
Date: Tue, 27 Sep 2011 00:50:07 -0400 (EDT)
Message-ID: <20110927.005007.66855821093335036.davem@davemloft.net>
References: <1317065858-3201-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toshiharu-linux@dsn.okisemi.com, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1I0EuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 00:50:14 -0400
In-Reply-To: <1317065858-3201-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 26 Sep 2011 14:37:38 -0500

> netdev is unused in pch_gbe_setup_rctl.  Remove this declaration to
> avoid a compiler warning.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied, thanks.
