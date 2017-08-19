From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] nfp: add basic ethtool callbacks to
 representors
Date: Fri, 18 Aug 2017 18:04:33 -0700 (PDT)
Message-ID: <20170818.180433.182193954731357475.davem@davemloft.net>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdHSBEe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 21:04:34 -0400
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 18 Aug 2017 15:48:10 -0700

> This set extends the basic ethtool functionality to representor
> netdevs.  I start with providing link state via ethtool and then
> move on to functions such as driver information, statistics and
> FW log dump.  The series contains a number of clean ups to the
> ethtool stats code too, some of the logic is simplified by making 
> better use of the nfp_port abstraction.  The stats we expose on 
> representors are only the PCIe and MAC port statistics firmware 
> maintains for us.

Looks good, series applied, thanks.
