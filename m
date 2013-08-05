From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2][net-next] gianfar: xmit - fix errata workaround
 and cleanup
Date: Mon, 05 Aug 2013 12:29:39 -0700 (PDT)
Message-ID: <20130805.122939.229807195384061697.davem@davemloft.net>
References: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620Ab3HET3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:29:40 -0400
In-Reply-To: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 5 Aug 2013 17:20:08 +0300

> Please find these cleanup patches for the gfar_start_xmit() function,
> including a fix for an old errata workaround implementation (eTSEC76,
> for MPC8313 and MPC837x). I find this cleanup quite necessary to make
> future fixes and improvements in xmit (and Tx processing) easier.

Both applied, thanks.
