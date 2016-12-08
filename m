From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2016-12-08
Date: Thu, 08 Dec 2016 18:23:28 -0500 (EST)
Message-ID: <20161208.182328.230441587883094644.davem@davemloft.net>
References: <20161208153552.18122-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753820AbcLHXXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 18:23:30 -0500
In-Reply-To: <20161208153552.18122-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu,  8 Dec 2016 16:35:51 +0100

> this is a pull request for one patch.
> 
> Jiho Chu found and fixed a use-after-free error in the cleanup path
> in the peak pcan USB CAN driver.

Pulled, thanks Marc.
