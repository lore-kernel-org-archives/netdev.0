From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2017-01-24,pull-request: can-next
 2017-01-24
Date: Fri, 27 Jan 2017 11:24:44 -0500 (EST)
Message-ID: <20170127.112444.682986770132734034.davem@davemloft.net>
References: <37eedb82-54d7-c7a9-0cd6-ed26738efff7@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932310AbdA0RIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:08:18 -0500
In-Reply-To: <37eedb82-54d7-c7a9-0cd6-ed26738efff7@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 27 Jan 2017 10:02:09 +0100

> this is a pull request of 4 patches for net-next/master.
> 
> The first patch by Oliver Hartkopp adds a netlink API to configure the
> interface termination of a CAN card. The next two patches are by me and
> add a netlink API to query and configure CAN interfaces that only
> support fixed bitrates. The last patch by Colin Ian King simplifies the
> return path in the softing_cs driver's softingcs_probe() function.

Pulled, thanks.
