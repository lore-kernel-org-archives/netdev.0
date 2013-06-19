From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-06-19
Date: Wed, 19 Jun 2013 00:48:13 -0700 (PDT)
Message-ID: <20130619.004813.1446078085522365696.davem@davemloft.net>
References: <1371625369-26368-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933328Ab3FSHsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 03:48:14 -0400
In-Reply-To: <1371625369-26368-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 19 Jun 2013 09:02:48 +0200

> here are there fixes for the v3.10 release cycle:
> 
> Michael Olbrich reported an Oops (free_netdev() on registered netdev) with the
> 8devices USB CAN converter on xhci USB host controllers. I've created a patch
> to fix the error path of the driver.

Pulled, thanks Marc.
