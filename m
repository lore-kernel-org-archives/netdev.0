From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and
 whitespace cleanups
Date: Mon, 04 Jun 2012 15:52:29 -0400 (EDT)
Message-ID: <20120604.155229.822064530175335346.davem@davemloft.net>
References: <1338827516-18425-6-git-send-email-jan.ceuleers@computer.org>
	<20120604.140850.1847853625568125563.davem@davemloft.net>
	<4FCD084D.6020408@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab2FDTwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:52:32 -0400
In-Reply-To: <4FCD084D.6020408@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon, 04 Jun 2012 21:11:09 +0200

> Well then I'm sorry but I won't be resubmitting

Because you can't test the build?

You absolutely can, on any architecture, that's how I found your typo.

Force the build with "make path/to/driver/foo.o" and scan through the
non-architecture-specific warnings and errors.
