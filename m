From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2: Add missing netif_tx_disable() in
 bnx2_close()
Date: Wed, 27 Jun 2012 21:28:47 -0700 (PDT)
Message-ID: <20120627.212847.915429786014663883.davem@davemloft.net>
References: <1340845704-12580-4-git-send-email-mchan@broadcom.com>
	<1340845704-12580-5-git-send-email-mchan@broadcom.com>
	<1340845704-12580-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab2F1E2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:28:47 -0400
In-Reply-To: <1340845704-12580-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Jun 2012 18:08:24 -0700

> to stop all tx queues.  Update version to 2.2.3.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
