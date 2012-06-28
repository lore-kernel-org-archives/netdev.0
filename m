From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] cnic: Remove uio mem[0].
Date: Wed, 27 Jun 2012 21:29:05 -0700 (PDT)
Message-ID: <20120627.212905.1093000568359854172.davem@davemloft.net>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
	<1340845704-12580-2-git-send-email-mchan@broadcom.com>
	<1340845704-12580-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab2F1E3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:29:06 -0400
In-Reply-To: <1340845704-12580-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Jun 2012 18:08:21 -0700

> This memory region is no longer used.  Userspace gets the BAR address
> directly from sysfs.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
