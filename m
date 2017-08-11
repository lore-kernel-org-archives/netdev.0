From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: send control message when MAC
 representors are created
Date: Fri, 11 Aug 2017 14:51:30 -0700 (PDT)
Message-ID: <20170811.145130.971248077968582666.davem@davemloft.net>
References: <1502439944-18910-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753738AbdHKVva (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:51:30 -0400
In-Reply-To: <1502439944-18910-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 11 Aug 2017 10:25:44 +0200

> The firmware expects a MAC_REPR control message when a MAC representor
> is created. The driver should expect a PORTMOD message to follow which
> will provide the link states of the physical port associated with the MAC
> representor.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Also applied, thanks Simon.
