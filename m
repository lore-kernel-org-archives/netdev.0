From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: fix BUG in HMAC init when preemption is
 enabled
Date: Tue, 10 Jan 2017 13:29:46 -0500 (EST)
Message-ID: <20170110.132946.149711848864334015.davem@davemloft.net>
References: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
        <CAHTyZGxoCV=fUjbUq2r5vtH2rDqGScrf=ty2HYOL8KLhdf4R4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.lebrun@uclouvain.be, netdev@vger.kernel.org
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756823AbdAJSaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:30:02 -0500
In-Reply-To: <CAHTyZGxoCV=fUjbUq2r5vtH2rDqGScrf=ty2HYOL8KLhdf4R4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ericnetdev dumazet <erdnetdev@gmail.com>

Oh noez, do we have an imposter? :-)
