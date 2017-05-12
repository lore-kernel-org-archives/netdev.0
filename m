From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ch9200: add missing USB-descriptor endianness
 conversions
Date: Fri, 12 May 2017 12:16:16 -0400 (EDT)
Message-ID: <20170512.121616.97072809822665919.davem@davemloft.net>
References: <20170512101326.2029-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: johan@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757671AbdELQQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:16:18 -0400
In-Reply-To: <20170512101326.2029-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hovold <johan@kernel.org>
Date: Fri, 12 May 2017 12:13:26 +0200

> Add the missing endianness conversions to a debug statement printing
> the USB device-descriptor idVendor and idProduct fields during probe.
> 
> Signed-off-by: Johan Hovold <johan@kernel.org>

Applied.
