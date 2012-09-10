From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] cnic: Allocate kcq resource only on
 devices that support FCoE.
Date: Mon, 10 Sep 2012 15:48:50 -0400 (EDT)
Message-ID: <20120910.154850.282258093680707418.davem@davemloft.net>
References: <1347120065-26492-2-git-send-email-mchan@broadcom.com>
	<1347120065-26492-3-git-send-email-mchan@broadcom.com>
	<1347120065-26492-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab2IJTsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:48:52 -0400
In-Reply-To: <1347120065-26492-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 8 Sep 2012 09:01:04 -0700

> To save memory and to exit IRQ loop quicker on devices that don't support
> FCoE.
> 
> Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
