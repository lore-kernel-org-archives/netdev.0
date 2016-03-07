From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Enable eTSEC-106 erratum w/a for MPC8548E Rev2
Date: Sun, 06 Mar 2016 22:45:23 -0500 (EST)
Message-ID: <20160306.224523.782432789307281226.davem@davemloft.net>
References: <20160303.090751.336624849.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org
To: nemoto@toshiba-tops.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbcCGDpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:45:25 -0500
In-Reply-To: <20160303.090751.336624849.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Date: Thu, 3 Mar 2016 09:07:51 +0900

> Enable workaround for MPC8548E erratum eTSEC 106,
> "Excess delays when transmitting TOE=1 large frames".
> (see commit 53fad77375ce "gianfar: Enable eTSEC-20 erratum w/a
> for P2020 Rev1")
> 
> This erratum was fixed in Rev 3.1.x.
> 
> Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>

Applied, thanks.
