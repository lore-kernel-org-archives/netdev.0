From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: mvneta: simple cleanups
Date: Wed, 15 Jan 2014 15:41:22 -0800 (PST)
Message-ID: <20140115.154122.1485420525760591929.davem@davemloft.net>
References: <cover.1389742334.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, thomas.petazzoni@free-electrons.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbaAOXlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:41:22 -0500
In-Reply-To: <cover.1389742334.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Ebalard <arno@natisbad.org>
Date: Wed, 15 Jan 2014 00:45:31 +0100

> 
> Those two patches are intended for net-next. They apply on top of
> performance improvements patches from Willy for mvneta driver.
> They provide some simple cleanups for unused variables, function
> params or return values.
> 
> Arnaud Ebalard (2):
>   net: mvneta: mvneta_tx_done_gbe() cleanups
>   net: mvneta: make mvneta_txq_done() return void

These patches do not apply to net-next, please respin.

Thanks.
