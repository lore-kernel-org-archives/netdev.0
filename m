From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2017-02-19
Date: Mon, 20 Feb 2017 11:15:28 -0500 (EST)
Message-ID: <20170220.111528.961250029250213130.davem@davemloft.net>
References: <20170219153956.GA28473@x1c>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750872AbdBTQPa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:15:30 -0500
In-Reply-To: <20170219153956.GA28473@x1c>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Sun, 19 Feb 2017 07:39:56 -0800

> Here's a set of Bluetooth patches for the 4.11 kernel:
> 
>  - New USB IDs to the btusb driver
>  - Race fix in btmrvl driver
>  - Added out-of-band wakeup support to the btusb driver
>  - NULL dereference fix to bt_sock_recvmsg
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks.
