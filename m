From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Sat, 09 Jul 2011 02:55:40 -0700 (PDT)
Message-ID: <20110709.025540.2298552254249041622.davem@davemloft.net>
References: <1310195566.25391.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab1GIJz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 05:55:59 -0400
In-Reply-To: <1310195566.25391.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shirley Ma <mashirle@us.ibm.com>
Date: Sat, 09 Jul 2011 00:12:46 -0700

> This patch clears tx zero-copy flag as needed.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

Applied, thanks.
