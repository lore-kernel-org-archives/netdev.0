From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio: add missing include to virtio_net.h
Date: Fri, 01 May 2009 15:34:17 -0700 (PDT)
Message-ID: <20090501.153417.135761259.davem@davemloft.net>
References: <20090428154654.19053.92829.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757532AbZEAWeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:34:23 -0400
In-Reply-To: <20090428154654.19053.92829.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Tue, 28 Apr 2009 09:46:54 -0600

> virtio_net.h uses the macro ETH_ALEN which is defined in linux/if_ether.h.
> Discovered when hacking on virtio-over-pci patches.
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Applied, thanks.
