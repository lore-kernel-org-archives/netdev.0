From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Fri, 26 Apr 2013 14:33:09 -0400 (EDT)
Message-ID: <20130426.143309.1011152996477262852.davem@davemloft.net>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	<CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	<20130426134415.GS1366@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, l.stach@pengutronix.de, netdev@vger.kernel.org,
	Frank.Li@freescale.com, festevam@gmail.com, shawn.guo@linaro.org
To: r.schwebel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab3DZSdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 14:33:11 -0400
In-Reply-To: <20130426134415.GS1366@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Schwebel <r.schwebel@pengutronix.de>
Date: Fri, 26 Apr 2013 15:44:15 +0200

> Seriously - it's friday, and 3.9 is expected to come out this
> weekend.

Seriously, it took you how long to notice the breakage and report
it in sufficient detail for the author to make an attempt at a fix?

I thnk Frank's request is reasonable given the circumstances, please
work closely with him on the fix.

Thanks.
