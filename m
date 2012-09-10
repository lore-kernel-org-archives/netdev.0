From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] cnic: Free UIO rings when the device is
 closed.
Date: Mon, 10 Sep 2012 15:48:38 -0400 (EDT)
Message-ID: <20120910.154838.712297839051082484.davem@davemloft.net>
References: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
	<1347120065-26492-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab2IJTsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:48:40 -0400
In-Reply-To: <1347120065-26492-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 8 Sep 2012 09:01:02 -0700

> This will free up unneeded memory.
> 
> Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
