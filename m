From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] ipv6: sr: export SRH insertion functions
Date: Fri, 04 Aug 2017 11:28:03 -0700 (PDT)
Message-ID: <20170804.112803.25649303424746.davem@davemloft.net>
References: <20170804132415.9701-1-david.lebrun@uclouvain.be>
        <20170804132415.9701-3-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdHDS2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 14:28:04 -0400
In-Reply-To: <20170804132415.9701-3-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Fri, 4 Aug 2017 15:24:12 +0200

> +EXPORT_SYMBOL(seg6_do_srh_encap);
 ...
> +EXPORT_SYMBOL(seg6_do_srh_inline);

EXPORT_SYMBOL_GPL() please.
