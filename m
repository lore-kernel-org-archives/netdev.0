From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] skge: Add DMA mask quirk for Marvell 88E8001 on
 ASUS P5NSLI motherboard.
Date: Mon, 08 Oct 2012 01:36:35 -0400 (EDT)
Message-ID: <20121008.013635.1877246075568372072.davem@davemloft.net>
References: <50711961.1010101@gmail.com>
	<507265B8.5070406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: graham.gower@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab2JHFgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 01:36:39 -0400
In-Reply-To: <507265B8.5070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham Gower <graham.gower@gmail.com>
Date: Mon, 08 Oct 2012 16:03:44 +1030

> +		.ident = "ASUS P5NSLI",
> +		.matches = {
> + DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
> +			DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")

This is poorly formatted, and your commit message has newlines
in very abrupt places as if you formatted it in your email client
GUI rather than in a text editor.
