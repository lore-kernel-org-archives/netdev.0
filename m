From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2017-06-14
Date: Wed, 14 Jun 2017 15:23:06 -0400 (EDT)
Message-ID: <20170614.152306.464199756760117197.davem@davemloft.net>
References: <20170614094421.GA29140@x1c.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdFNTXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:23:11 -0400
In-Reply-To: <20170614094421.GA29140@x1c.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Wed, 14 Jun 2017 12:44:21 +0300

> Here's another batch of Bluetooth patches for the 4.13 kernel:
> 
>  - Fix for Broadcom controllers not supporting Event Mask Page 2
>  - New QCA ROME USB ID for btusb
>  - Fix for Security Manager Protocol to use constant-time memcmp
>  - Improved support for TI WiLink chips
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
