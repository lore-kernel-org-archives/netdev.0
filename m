From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] cnic: Add FCoE parity error recovery
Date: Sun, 05 Feb 2012 22:46:51 -0500 (EST)
Message-ID: <20120205.224651.851906107615572471.davem@davemloft.net>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
	<1328491480-13030-2-git-send-email-mchan@broadcom.com>
	<1328491480-13030-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab2BFDrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 22:47:23 -0500
In-Reply-To: <1328491480-13030-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 5 Feb 2012 17:24:40 -0800

> When bnx2x returns error on FCoE SPQ messages, generate an error
> completion to bnx2fc immediately to speed up error recovery.  This
> will eliminate length timeouts and spped up the reset of the device.
> 
> Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
