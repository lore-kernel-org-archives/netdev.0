From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2016-12-03
Date: Mon, 05 Dec 2016 13:38:15 -0500 (EST)
Message-ID: <20161205.133815.1023757623950335762.davem@davemloft.net>
References: <20161203195341.GA17607@x1c.ukservers.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbcLESip (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:38:45 -0500
In-Reply-To: <20161203195341.GA17607@x1c.ukservers.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Sat, 3 Dec 2016 19:53:41 +0000

> Here's a set of Bluetooth & 802.15.4 patches for net-next (i.e. 4.10
> kernel):
> 
>  - Fix for a potential NULL deref in the ieee802154 netlink code
>  - Fix for the ED values of the at86rf2xx driver
>  - Documentation updates to ieee802154
>  - Cleanups to u8 vs __u8 usage
>  - Timer API usage cleanups in HCI drivers
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
