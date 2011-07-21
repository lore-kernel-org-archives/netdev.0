From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] cnic: Fix Context ID space calculation
Date: Thu, 21 Jul 2011 12:47:26 -0700 (PDT)
Message-ID: <20110721.124726.8787778319098033.davem@davemloft.net>
References: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab1GUTr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 15:47:28 -0400
In-Reply-To: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 20 Jul 2011 17:55:22 -0700

> Include FCoE CID space only for E2_PLUS devices.  Remove old CID
> offset adjustments that are no longer needed.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
