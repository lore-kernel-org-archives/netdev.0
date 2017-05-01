From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qed: RoCE related pseudo-fixes
Date: Sun, 30 Apr 2017 22:59:05 -0400 (EDT)
Message-ID: <20170430.225905.1944000115277149419.davem@davemloft.net>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ram.Amrani@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753059AbdEAC7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:59:07 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 30 Apr 2017 11:49:04 +0300

> This series contains multiple small corrections to the RoCE logic
> in qed plus some debug information and inter-module parameter
> meant to prevent issues further along.
> 
>  - #1, #6 Share information with protocol driver
>    [either new or filling missing bits in existing API].
>  - #2, #3 correct error flows in qed.
>  - #4 add debug related information.
>  - #5 fixes a minor issue in the HW configuration.

Series applied, thanks.
