From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] cnic: Add timeout for ramrod replies.
Date: Sun, 28 Aug 2011 17:08:58 -0400 (EDT)
Message-ID: <20110828.170858.694157288426156003.davem@davemloft.net>
References: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
	<1314387941-2126-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab1H1VJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 17:09:00 -0400
In-Reply-To: <1314387941-2126-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 26 Aug 2011 12:45:40 -0700

> If the bnx2x device has encountered parity errors, the chip will not DMA
> any replies.  Using wait_event_timeout() will allow us to make forward
> progress and let bnx2x reset the chip.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
