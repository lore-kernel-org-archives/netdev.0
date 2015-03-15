From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] gianfar: ARM port driver updates (2/2)
Date: Sun, 15 Mar 2015 19:57:31 -0400 (EDT)
Message-ID: <20150315.195731.444719912848144694.davem@davemloft.net>
References: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbbCOX5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 19:57:34 -0400
In-Reply-To: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 13 Mar 2015 10:36:27 +0200

> The 2nd round of driver updates to make gianfar portable on ARM,
> for the ARM based SoC that integrates eTSEC - "ls1021a".
> The patches address the bulk of remaining endianess issues -
> handling DMA fields (BD and FCB), and device tree properties.

Series applied to net-next, thanks.
