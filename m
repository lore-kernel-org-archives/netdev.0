From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] alx: add feature flag for rx checksumming
Date: Mon, 09 Jan 2017 14:53:05 -0500 (EST)
Message-ID: <20170109.145305.529742417822882925.davem@davemloft.net>
References: <20170109121555.4592-1-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965412AbdAITxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:53:07 -0500
In-Reply-To: <20170109121555.4592-1-tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Mon,  9 Jan 2017 13:15:55 +0100

> The code to handle rx checksumming was in the driver since its introduction
> but for reasons unknown the feature flag was left out. Now it is possible
> to enable this feature with ethtool.
> 
> Tested on my AR8161 ethernet card, there are no regressions observed in
> netperf if this feature is enabled.
> 
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>

Applied, thanks.
