From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and
 whitespace cleanups
Date: Mon, 04 Jun 2012 14:08:50 -0400 (EDT)
Message-ID: <20120604.140850.1847853625568125563.davem@davemloft.net>
References: <1338827516-18425-1-git-send-email-jan.ceuleers@computer.org>
	<1338827516-18425-6-git-send-email-jan.ceuleers@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786Ab2FDSJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 14:09:11 -0400
In-Reply-To: <1338827516-18425-6-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon,  4 Jun 2012 18:31:56 +0200

> -					sizeof(struct gfar_mask_entry),
> -					gfar_comp, &gfar_swap);
> +			     sizeof(struct gfar_mask_entry),
> +			     far_comp, &gfar_swap);

Don't send me crap you haven't even compile tested.

I'm tossing this entire patch series out, don't resubmit until you've
tested every single patch.
