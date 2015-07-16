From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2015-07-15
Date: Wed, 15 Jul 2015 17:27:34 -0700 (PDT)
Message-ID: <20150715.172734.2200806855246018316.davem@davemloft.net>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbbGPA1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 20:27:35 -0400
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 15 Jul 2015 09:09:37 +0200

> this is a pull request of 12 patches by me.
> 
> This series fixes the use of the skb after netif_receive_skb() /
> netif_rx() which exists in several drivers.

Pulled, thanks Marc.
