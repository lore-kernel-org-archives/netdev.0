From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 0/3] asix: Improve robustness
Date: Mon, 07 Aug 2017 10:11:06 -0700 (PDT)
Message-ID: <20170807.101106.1909460831831347182.davem@davemloft.net>
References: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Dean_Jenkins@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdHGRLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:11:07 -0400
In-Reply-To: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Jenkins <Dean_Jenkins@mentor.com>
Date: Mon, 7 Aug 2017 09:50:13 +0100

> Please consider taking these patches to improve the robustness of the ASIX USB
> to Ethernet driver.

I applied these to 'net' since they are bug fixes.

Please target bug fixes to 'net' instead of 'net-next' in the
future, unless they are fixing problems which only exist in
'net-next'.

Thanks.
