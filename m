From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Thu, 08 Jun 2017 19:17:12 -0400 (EDT)
Message-ID: <20170608.191712.1829919738916549276.davem@davemloft.net>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw@amazon.com, zorik@amazon.com,
        matua@amazon.com, saeedb@amazon.com, msw@amazon.com,
        aliguori@amazon.com, nafea@amazon.com, evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdFHXRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:17:16 -0400
In-Reply-To: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two parallel patch series to the same driver and targetting the
same GIT tree is extremely undesirable, please don't do this.

Submit one series, and once applied submit the second series.

I'm deleting all of your patches from my queue, please resubmit
things properly.

Thank you.
