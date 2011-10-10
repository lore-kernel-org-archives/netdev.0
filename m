From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix cl_id allocation for non-eth clients
 for NPAR mode
Date: Mon, 10 Oct 2011 14:20:56 -0400 (EDT)
Message-ID: <20111010.142056.1563166608709480896.davem@davemloft.net>
References: <1318240656-24657-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083Ab1JJSVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:21:01 -0400
In-Reply-To: <1318240656-24657-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 10 Oct 2011 11:57:36 +0200

> There are some consolidations of NPAR configuration
> when FCoE and iSCSI L2 clients will get the same id,
> in this case FCoE ring will be non-functional.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

I'll apply this, thanks.
