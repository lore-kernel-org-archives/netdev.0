From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2016-11-23
Date: Fri, 25 Nov 2016 16:18:11 -0500 (EST)
Message-ID: <20161125.161811.1838949976006608717.davem@davemloft.net>
References: <20161123143430.24985-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbcKYVSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:18:15 -0500
In-Reply-To: <20161123143430.24985-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 23 Nov 2016 15:34:29 +0100

> this is a pull request for net/master.
> 
> The patch by Oliver Hartkopp for the broadcast manager (bcm) fixes the CAN-FD
> support, which may cause an out-of-bounds access otherwise.

Pulled, thanks.
