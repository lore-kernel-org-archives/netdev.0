From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2017-04-25
Date: Tue, 25 Apr 2017 11:21:26 -0400 (EDT)
Message-ID: <20170425.112126.232541678435322858.davem@davemloft.net>
References: <20170425121645.9946-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948864AbdDYPV2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:21:28 -0400
In-Reply-To: <20170425121645.9946-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 25 Apr 2017 14:16:42 +0200

> this is a pull request of three patches for net/master.
> 
> There are two patches by Stephane Grosjean for that add a new variant to the
> PCAN-Chip USB driver. The other patch is by Maksim Salau, which swtiches the
> memory for USB transfers from heap to stack.

I think you meant "from stack to heap", but anyways pulled thanks!
