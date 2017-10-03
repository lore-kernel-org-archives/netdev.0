From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Tue, 03 Oct 2017 16:03:38 -0700 (PDT)
Message-ID: <20171003.160338.1370433279322133749.davem@davemloft.net>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: richard_siegfried@systemli.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdJCXDk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 19:03:40 -0400
In-Reply-To: <20171003222213.7996-1-richard_siegfried@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Sailer <richard_siegfried@systemli.org>
Date: Wed,  4 Oct 2017 00:22:10 +0200

> net/ipv4 currently contains around 100 source files containing the
> IP implementation and lots of other functionality (UDP, TCP, xfrm, etc.)

As someone who has to do backports regularly to -stable, there is no way
I am applying this.

Sorry.
