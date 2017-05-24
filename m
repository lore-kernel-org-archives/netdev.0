From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/11] qed/qede: Mostly-cleanup series
Date: Wed, 24 May 2017 15:18:13 -0400 (EDT)
Message-ID: <20170524.151813.1415690265134906703.davem@davemloft.net>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934210AbdEXTS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:18:26 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Tue, 23 May 2017 09:41:17 +0300

> This series contains some cleanup of the qed and qede code:
>  - #1 contains mostly static/endian changes in order to allow qede to
>    pass sparse compilation cleanly.
>  - #2, #5 and #6 are either semantic or remove dead-code from driver.
>  - #9, #10 and #11 relate to printing and slightly change some APIs
>    between qed and the protocol drivers for that end [sharing the
>    interface names and information regarding device].
> 
> The rest of the patches are minor changes/fixes to various flows
> in qed.

Series applied, thanks.
