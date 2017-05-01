From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2017-04-30
Date: Sun, 30 Apr 2017 23:03:36 -0400 (EDT)
Message-ID: <20170430.230336.142225761153252889.davem@davemloft.net>
References: <20170430140928.GA2753@x1c>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756784AbdEADDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 23:03:38 -0400
In-Reply-To: <20170430140928.GA2753@x1c>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Sun, 30 Apr 2017 17:09:28 +0300

> Here's one last batch of Bluetooth patches in the bluetooth-next tree
> targeting the 4.12 kernel.
> 
>  - Remove custom ECDH implementation and use new KPP API instead
>  - Add protocol checks to hci_ldisc
>  - Add module license to HCI UART Nokia H4+ driver
>  - Minor fix for 32bit user space - 64 bit kernel combination
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
