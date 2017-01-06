From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: make fib_select_default static
Date: Fri, 06 Jan 2017 15:58:02 -0500 (EST)
Message-ID: <20170106.155802.1724754138892702688.davem@davemloft.net>
References: <1483673639-14417-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdAFU6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:58:03 -0500
In-Reply-To: <1483673639-14417-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  5 Jan 2017 19:33:59 -0800

> fib_select_default has a single caller within the same file.
> Make it static.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Also applied, thanks David.
