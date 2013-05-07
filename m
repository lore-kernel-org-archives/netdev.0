From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 07 May 2013 07:17:02 -0400 (EDT)
Message-ID: <20130507.071702.1197542321916175250.davem@davemloft.net>
References: <1367898205-6272-1-git-send-email-Frank.Li@freescale.com>
	<1367920728.4126.32.camel@weser.hi.pengutronix.de>
	<CAHrpEqQFeqzyjT6EgzULZVC-bQU_juUMddBzuMfoN7+jppF2MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.stach@pengutronix.de, Frank.Li@freescale.com,
	romieu@fr.zoreil.com, r.schwebel@pengutronix.de,
	netdev@vger.kernel.org, festevam@gmail.com, shawn.guo@linaro.org
To: lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185Ab3EGLPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 07:15:04 -0400
In-Reply-To: <CAHrpEqQFeqzyjT6EgzULZVC-bQU_juUMddBzuMfoN7+jppF2MQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'll put it into my -stable queue.
