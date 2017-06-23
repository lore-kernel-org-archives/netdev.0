From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 00/11] update ena ethernet driver to
 version 1.2.0
Date: Fri, 23 Jun 2017 14:16:37 -0400 (EDT)
Message-ID: <20170623.141637.194178237902883118.davem@davemloft.net>
References: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw@amazon.com, zorik@amazon.com,
        matua@amazon.com, saeedb@amazon.com, msw@amazon.com,
        aliguori@amazon.com, nafea@amazon.com, evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754237AbdFWSQj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:16:39 -0400
In-Reply-To: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <netanel@amazon.com>
Date: Fri, 23 Jun 2017 11:21:49 +0300

> From: Netanel Belgazal <netanel@amazon.com>
> 
> This patchset contains some new features/improvements that were added
> to the ENA driver to increase its robustness and are based on
> experience of wide ENA deployment.
> 
> Change log:
> 
> V2:
> * Remove patch that add inline to C-file static function (contradict coding style).
> * Remove patch that moves MTU parameter validation in ena_change_mtu() instead of
> using the network stack.
> * Use upper_32_bits()/lower_32_bits() instead of casting.

Series applied, thanks.
