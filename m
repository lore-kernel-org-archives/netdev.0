From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tulip: explicity set to D0 power state during init
Date: Tue, 01 Jun 2010 00:18:16 -0700 (PDT)
Message-ID: <20100601.001816.57452131.davem@davemloft.net>
References: <AANLkTilr33y7rlJpjto5blK4wXKaVst1O4IM0JgPNP7B@mail.gmail.com>
	<1275361913-5630-1-git-send-email-stevenrwalter@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
To: stevenrwalter@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754483Ab0FAHSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:18:06 -0400
In-Reply-To: <1275361913-5630-1-git-send-email-stevenrwalter@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Walter <stevenrwalter@gmail.com>
Date: Mon, 31 May 2010 23:11:53 -0400

> During the first suspend the chip would refuse to enter D3.  Subsequent
> suspends worked okay.  During resume the chip is commanded into D0.
> Doing so during initialization fixes the initial suspend.
> 
> Signed-off-by: Steven Walter <stevenrwalter@gmail.com>
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

Applied.
