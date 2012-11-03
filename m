From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, RESEND] r8169: Kill SafeMtu macro
Date: Sat, 03 Nov 2012 14:59:27 -0400 (EDT)
Message-ID: <20121103.145927.938662941593447912.davem@davemloft.net>
References: <20121029175512.GA13577@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: kirr@mns.spb.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab2KCS73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:59:29 -0400
In-Reply-To: <20121029175512.GA13577@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kirill Smelkov <kirr@mns.spb.ru>
Date: Mon, 29 Oct 2012 21:55:12 +0400

> After d58d46b5 (r8169: jumbo fixes.) max frame len is stored in
> rtl_chip_infos[].jumbo_max for each chip and SafeMtu should be gone.
> 
> Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>

Applied.
