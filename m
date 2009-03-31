From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: only for x86 or 64-bit at the moment...
Date: Tue, 31 Mar 2009 14:15:42 -0700 (PDT)
Message-ID: <20090331.141542.182956594.davem@davemloft.net>
References: <20090331210609.GD25513@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: kyle@mcmartin.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42644
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754783AbZCaVPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:15:54 -0400
In-Reply-To: <20090331210609.GD25513@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@mcmartin.ca>
Date: Tue, 31 Mar 2009 17:06:09 -0400

> From: Kyle McMartin <kyle@redhat.com>
> 
> set_64bit doesn't exist anywhere but x86 right now, so either
> BITS_PER_LONG needs to be 64, or we need to be on x86, in order to
> build this module.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

I would prefer the RDS folks simply fix this properly.
