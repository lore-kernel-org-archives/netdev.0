From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: Add driver helper functions to
 determine checksum offloadability"
Date: Fri, 14 Oct 2016 10:03:54 -0400 (EDT)
Message-ID: <20161014.100354.446956331078920051.davem@davemloft.net>
References: <20161011130409.7e6b54ff@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753492AbcJNOD7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:03:59 -0400
In-Reply-To: <20161011130409.7e6b54ff@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 11 Oct 2016 13:04:09 -0700

> 
> This reverts commit 6ae23ad36253a8033c5714c52b691b84456487c5.
> 
> The code has been in kernel since 4.4 but there are no in tree
> code that uses. Unused code is broken code, remove it.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied to net-next, thanks Stephen.

Please put proper "[PATCH net-next]" tags in your Subject lines when
patches are targetting net-next.

Thanks.
