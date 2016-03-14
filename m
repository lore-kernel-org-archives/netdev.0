From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/fman: fix dtsec_set_tx_pause_frames
Date: Mon, 14 Mar 2016 15:03:33 -0400 (EDT)
Message-ID: <20160314.150333.107371462585730135.davem@davemloft.net>
References: <1457896483-7942-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbcCNTDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:03:36 -0400
In-Reply-To: <1457896483-7942-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <igal.liberman@freescale.com>
Date: Sun, 13 Mar 2016 21:14:43 +0200

> From: Igal Liberman <igal.liberman@freescale.com>
> 
> Fix a bug introduced in e06a03b (fsl/fman: fix the pause_time test)
> When pause_time is set to '0' - pause frames are disabled and
> there's no need to apply dTSEC-A003 Errata workaround.
> 
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>

Applied, thank you.
