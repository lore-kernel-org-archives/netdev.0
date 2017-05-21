From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] qed/qede updates
Date: Sun, 21 May 2017 13:01:41 -0400 (EDT)
Message-ID: <20170521.130141.1217220690269746260.davem@davemloft.net>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbdEURBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:01:54 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 21 May 2017 12:10:51 +0300

> This series contains some general minor fixes and enhancements:
> 
>  - #1, #2 and #9 correct small missing ethtool functionality.
>  - #3, #6  and #8 correct minor issues in driver, but those are either
>    print-related or unexposed in existing code.
>  - #4 adds proper support to TLB mode bonding.
>  - #10 is meant to improve performance on varying cache-line sizes.
> 
> Dave,
> 
> Please consider applying this to `net-next'.

Series applied, thank you.
