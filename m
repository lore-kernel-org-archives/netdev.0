From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] fec: switch to writel/readl
Date: Thu, 16 Apr 2009 02:36:17 -0700 (PDT)
Message-ID: <20090416.023617.186495875.davem@davemloft.net>
References: <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
	<20090415131130.GW14383@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@snapgear.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752825AbZDPJg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:36:26 -0400
In-Reply-To: <20090415131130.GW14383@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 15 Apr 2009 15:11:30 +0200

> Since the second register set is used for M5272 we cannot remove it.
> Here is an updated version.

Applied.
