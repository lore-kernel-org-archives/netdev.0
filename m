From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] ixp4xx_eth: fix ptp_ixp46x build failure
Date: Mon, 06 Aug 2012 13:31:13 -0700 (PDT)
Message-ID: <20120806.133113.996150251709070253.davem@davemloft.net>
References: <20120805203042.509148064@rtp-net.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl
To: arnaud.patard@rtp-net.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756141Ab2HFUbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:31:14 -0400
In-Reply-To: <20120805203042.509148064@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Date: Sun, 05 Aug 2012 22:30:11 +0200

> When building with ixp4xx_eth and ptp_ixp46x as module, one is getting the
> following error:
> 
> ERROR: "ixp46x_phc_index" [drivers/ptp/ptp_ixp46x.ko] undefined!
> 
> This has been introduced by commit 509a7c25729feab353502e1b544c614772a1d49a.
> 
> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>

Applied.
