From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixgbe: get rid of custom busy polling code
Date: Fri, 03 Feb 2017 16:21:56 -0500 (EST)
Message-ID: <20170203.162156.1840619893055262718.davem@davemloft.net>
References: <1486081599.21871.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752564AbdBCVWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:22:20 -0500
In-Reply-To: <1486081599.21871.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Intel folks please review these two patches, as I need to apply them in order
to add Eric's final patch which removes the busy polling NDO op altogether.

	http://patchwork.ozlabs.org/patch/723356/

Thank you.
