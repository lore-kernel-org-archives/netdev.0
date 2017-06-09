From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 09 Jun 2017 14:54:34 -0400 (EDT)
Message-ID: <20170609.145434.399590645965329804.davem@davemloft.net>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
        <20170609102104.34c26568@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdFISyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 14:54:38 -0400
In-Reply-To: <20170609102104.34c26568@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 9 Jun 2017 10:21:04 -0700

> Is there anything in Documentation/networking/netdevices.txt about this to
> avoid any future issues?

You asked me about this last time, and I did not forget about it.

I sincerely lack the time to do a writeup about it, and I felt that
delaying the fix for another week or two until I find that magical
non-existing timeframe to write the docs was not beneficial for
users at all.
