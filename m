From: David Miller <davem@davemloft.net>
Subject: Re: [patch] [SCSI] bnx2i: use strlcpy() instead of memcpy() for
 strings
Date: Sun, 08 Jul 2012 23:51:30 -0700 (PDT)
Message-ID: <20120708.235130.1792833004317144162.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F6F@saturn3.aculab.com>
	<20120702104843.GB4519@mwanda>
	<1341242018.7472.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, David.Laight@ACULAB.COM,
	JBottomley@parallels.com, barak@broadcom.com,
	eddie.wai@broadcom.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab2GIGvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 02:51:31 -0400
In-Reply-To: <1341242018.7472.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 2 Jul 2012 08:13:38 -0700

> This came from the net-next tree, so David is the right persion to apply
> this.  Thanks.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
