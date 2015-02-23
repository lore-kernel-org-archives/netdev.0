From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth 2015-02-23
Date: Mon, 23 Feb 2015 15:06:20 -0500 (EST)
Message-ID: <20150223.150620.1748896587152404088.davem@davemloft.net>
References: <20150223074526.GA8287@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbBWUGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 15:06:23 -0500
In-Reply-To: <20150223074526.GA8287@t440s.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Mon, 23 Feb 2015 09:45:26 +0200

> Here's one important fix for the 4.0-rc series. Refactoring of Intel
> Bluetooth controller detection ended up disabling some older ones which
> are based on CSR hardware. This patch re-introduces the necessary USB id
> and fixes the breakage.
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
