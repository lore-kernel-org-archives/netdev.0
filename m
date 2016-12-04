From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix the missing avr32
 SOF_TIMESTAMPING_OPT_STATS
Date: Sat, 03 Dec 2016 19:06:28 -0500 (EST)
Message-ID: <20161203.190628.1312678809229079294.davem@davemloft.net>
References: <1480805182-7150-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751596AbcLDAGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:06:35 -0500
In-Reply-To: <1480805182-7150-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Sat,  3 Dec 2016 14:46:22 -0800

> The commit of SOF_TIMESTAMPING_OPT_STATS didn't include the
> new header for avr32, causing build to break. The patch fixes it.
> 
> Fixes: 1c885808e456 ("tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING")
> Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
