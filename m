From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net/can: the mailinglist moved to vger.kernel.org
Date: Fri, 14 Oct 2011 13:59:57 -0400 (EDT)
Message-ID: <20111014.135957.1362990461764808801.davem@davemloft.net>
References: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
	<1318581817-12352-4-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558Ab1JNSBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 14:01:07 -0400
In-Reply-To: <1318581817-12352-4-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 14 Oct 2011 10:43:36 +0200

> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Please, just remove these references from the source files, they
absolutely do not belong there.

The MAINTAINERS file is the place to obtain this kind of information
and automated tools can let you know which MAINTAINERS entry applies
to a particular source file as long as the entry has appropriate file
tags.

Thanks.
