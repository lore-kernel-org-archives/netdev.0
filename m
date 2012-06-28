From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] cnic: Handle RAMROD_CMD_ID_CLOSE error.
Date: Wed, 27 Jun 2012 21:29:11 -0700 (PDT)
Message-ID: <20120627.212911.2242472640950683711.davem@davemloft.net>
References: <1340845704-12580-2-git-send-email-mchan@broadcom.com>
	<1340845704-12580-3-git-send-email-mchan@broadcom.com>
	<1340845704-12580-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab2F1E3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:29:11 -0400
In-Reply-To: <1340845704-12580-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Jun 2012 18:08:22 -0700

> From: Eddie Wai <eddie.wai@broadcom.com>
> 
> If firmware returns error status, proceed to close the iSCSI connection.
> Update version to 2.5.11.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
