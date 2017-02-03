From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_lookup.h from devinet.c
 include list
Date: Thu, 02 Feb 2017 23:09:20 -0500 (EST)
Message-ID: <20170202.230920.2189727961162411004.davem@davemloft.net>
References: <1486003285-2146-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdBCEJW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:09:22 -0500
In-Reply-To: <1486003285-2146-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  1 Feb 2017 18:41:25 -0800

> nothing in devinet.c relies on fib_lookup.h; remove it from the includes
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
