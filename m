From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: fix inability to set offloads after disabling
 them via ethtool
Date: Tue, 21 Mar 2017 15:31:25 -0700 (PDT)
Message-ID: <20170321.153125.2107918979977138191.davem@davemloft.net>
References: <58caeb36.0a212e0a.87e63.3119@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yaroslav.isakov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933347AbdCUWbq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:31:46 -0400
In-Reply-To: <58caeb36.0a212e0a.87e63.3119@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Date: Thu, 16 Mar 2017 22:44:10 +0300

> Added missing logic in tun driver, which prevents apps to set
> offloads using tun ioctl, if offloads were previously disabled via ethtool
> 
> Signed-off-by: Yaroslav Isakov <yaroslav.isakov@gmail.com>

Applied, thanks.
