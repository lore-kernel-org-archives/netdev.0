From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] cnic: Reset iSCSI EQ during shutdown.
Date: Wed, 05 Dec 2012 16:26:29 -0500 (EST)
Message-ID: <20121205.162629.467066788064135451.davem@davemloft.net>
References: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096Ab2LEV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:26:30 -0500
In-Reply-To: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 5 Dec 2012 12:10:14 -0800

> Without the reset, reloading the cnic driver can cause the iSCSI
> Event Queue to be out of sync with the driver and cause intermittent
> crash.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Acked-by: Ariel Elior <ariele@broadcom.com>

Applied.
