From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vlan: fix nlmsg size calculation in
 vlan_get_size()
Date: Tue, 08 Oct 2013 16:53:00 -0400 (EDT)
Message-ID: <20131008.165300.952208886283983249.davem@davemloft.net>
References: <1381180798-26654-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de, kaber@trash.net
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab3JHUxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:53:02 -0400
In-Reply-To: <1381180798-26654-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon,  7 Oct 2013 23:19:58 +0200

> This patch fixes the calculation of the nlmsg size, by adding the missing
> nla_total_size().
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.
