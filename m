From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 13:46:53 -0400 (EDT)
Message-ID: <20110614.134653.607599293786464713.davem@davemloft.net>
References: <201106141922.40906.vladz@broadcom.com>
	<20110614.133200.1595212089561436266.davem@davemloft.net>
	<1308072953.9492.4.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, bprakash@broadcom.com, eilong@broadcom.com,
	netdev@vger.kernel.org, dmitry@broadcom.com,
	yaniv.rosner@broadcom.com, dwmw2@infradead.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281Ab1FNRsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:48:00 -0400
In-Reply-To: <1308072953.9492.4.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 14 Jun 2011 10:35:53 -0700

> If the firmware is not integrated into net-next-2.6, the newly patched
> driver won't work.  You get an error at run time saying the firmware is
> not available.
> 
> When David Woodhouse integrates the firmware and a new firmware rpm is
> made available for users, then the new driver will work.

This is terrible.
