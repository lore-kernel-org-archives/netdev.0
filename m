From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] nfp: extend match and action for flower
 offload
Date: Fri, 06 Oct 2017 09:56:54 -0700 (PDT)
Message-ID: <20171006.095654.1999581607548088854.davem@davemloft.net>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdJFQ4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 12:56:54 -0400
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri,  6 Oct 2017 10:21:19 +0200

> Pieter says:
> 
> This series extends flower offload match and action capabilities. It
> specifically adds offload capabilities for matching on MPLS, TTL, TOS
> and flow label. Furthermore offload capabilities for action have been
> expanded to include set ethernet, ipv4, ipv6, tcp and udp headers.

Series applied, thanks Simon.
