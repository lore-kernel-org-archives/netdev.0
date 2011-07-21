From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-next] cnic: Wait for all Context IDs to be
 deleted before sending FCOE_DESTROY_FUNC
Date: Thu, 21 Jul 2011 12:47:34 -0700 (PDT)
Message-ID: <20110721.124734.1477688410135283176.davem@davemloft.net>
References: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
	<1311209725-10414-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab1GUTrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 15:47:36 -0400
In-Reply-To: <1311209725-10414-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 20 Jul 2011 17:55:23 -0700

> Otherwise, the firmware will not respond and we'll have to wait for
> timeout.  Refactor the wait loop we already have into a separate
> function for this purpose.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
