From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6] cnic: Return proper error code if we fail
 to send netlink message
Date: Thu, 14 Jul 2011 08:46:39 -0700 (PDT)
Message-ID: <20110714.084639.773975306235103350.davem@davemloft.net>
References: <1310613862-27497-2-git-send-email-mchan@broadcom.com>
	<1310613862-27497-3-git-send-email-mchan@broadcom.com>
	<1310613862-27497-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1GNPql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 11:46:41 -0400
In-Reply-To: <1310613862-27497-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 13 Jul 2011 20:24:20 -0700

> to allow iSCSI connection to fail faster instead of waiting for the
> long timeout.
> 
> Update version to 2.5.6.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
