From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] update ENA driver to releawse 1.3.0
Date: Thu, 19 Oct 2017 12:52:37 +0100 (WEST)
Message-ID: <20171019.125237.1377781386233593824.davem@davemloft.net>
References: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw@amazon.com, zorik@amazon.com,
        matua@amazon.com, saeedb@amazon.com, msw@amazon.com,
        aliguori@amazon.com, nafea@amazon.com, evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751680AbdJSLws (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:52:48 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <netanel@amazon.com>
Date: Tue, 17 Oct 2017 07:33:55 +0000

> From: Netanel Belgazal <netanel@amazon.com>
> 
> Netanel Belgazal (6):
>   net: ena: improve ENA driver boot time.
>   net: ena: remove legacy suspend suspend/resume support
>   net: ena: add power management ops to the ENA driver
>   net: ena: add statistics for missed tx packets
>   net: ena: add new admin define for future support of IPv6 RSS
>   net: ena: increase ena driver version to 1.3.0

Series applied, but this is a terrible header posting.

You should have real content here.  You need to provide text
explaining, at a high level, what the patch series is doing,
how it is doing it, and why it is doing it that way.

Please don't provide an empty header posting like this in
the future.

Thank you.
