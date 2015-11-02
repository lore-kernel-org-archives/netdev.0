From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2015-10-30
Date: Mon, 02 Nov 2015 15:34:39 -0500 (EST)
Message-ID: <20151102.153439.775851202228554682.davem@davemloft.net>
References: <1446212399-31546-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbKBUel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:34:41 -0500
In-Reply-To: <1446212399-31546-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 30 Oct 2015 14:39:58 +0100

> this is a pull request for the upcoming v4.3 release.
> 
> Marek Vasut provides a patch to use the correct attrlen in the nla_put() in the
> can_fill_info() function.

Pulled, but this missed the v4.3 release so you'll need to push this explicitly
out to -stable.

Thanks.
