From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment
 Routing
Date: Wed, 09 Nov 2016 20:40:58 -0500 (EST)
Message-ID: <20161109.204058.1740541278564630528.davem@davemloft.net>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbcKJBlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:41:01 -0500
In-Reply-To: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Series applied, but I wonder if using a Kconfig knob for the INLINE thing
is overkill.
