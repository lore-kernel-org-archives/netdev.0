From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] bnx2x,bnx2fc,bnx2i,cnic: Add statistics
 support and FCoE capabilities advertisement
Date: Wed, 27 Jun 2012 01:20:25 -0700 (PDT)
Message-ID: <20120627.012025.1523809034577127170.davem@davemloft.net>
References: <1340703387-16263-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, barak@broadcom.com,
	eddie.wai@broadcom.com, mchan@broadcom.com, bprakash@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab2F0IU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:20:26 -0400
In-Reply-To: <1340703387-16263-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Tue, 26 Jun 2012 12:36:27 +0300

> From: Barak Witkowski <barak@broadcom.com>
> 
> 1. When FCoE offload driver is registered, copy its capabilities to the chip
>    scratchpad.
> 2. Copy FCoE/iSCSI MAC addresses in aligned manner to chip scratchpad.
> 3. Add FCoE/iSCSI statistics collection support
> 
> Signed-off-by: Barak Witkowski <barak@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
