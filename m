From: David Miller <davem@davemloft.net>
Subject: Re: [resend PATCH] irda: use PCI_VENDOR_ID_*
Date: Wed, 03 Aug 2011 19:04:25 -0700 (PDT)
Message-ID: <20110803.190425.2134500040590013480.davem@davemloft.net>
References: <1312389762-9728-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab1HDCFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 22:05:36 -0400
In-Reply-To: <1312389762-9728-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Wed,  3 Aug 2011 11:42:42 -0500

> Use PCI_VENDOR_ID_* from pci_ids.h instead of creating #define locally.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied, thanks.
