From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2017-08-01
Date: Tue, 01 Aug 2017 17:43:38 -0700 (PDT)
Message-ID: <20170801.174338.1066495009711747378.davem@davemloft.net>
References: <20170801094156.GA22557@x1c.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbdHBAnj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 20:43:39 -0400
In-Reply-To: <20170801094156.GA22557@x1c.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Tue, 1 Aug 2017 12:41:56 +0300

> Here's our first batch of Bluetooth patches for the 4.14 kernel:
> 
>  - Several new USB IDs for the btusb driver
>  - Memory leak fix in btusb driver
>  - Cleanups & fixes to hci_nokia, hci_serdev and hci_bcm drivers
>  - Fixed cleanup path in mrf24j40 (802.15.4) driver probe function
>  - A few other smaller cleanups & fixes to drivers
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thank you.
