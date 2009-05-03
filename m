From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ne2k-pci: use dev->addr_len instead of "6"
Date: Sun, 03 May 2009 14:20:54 -0700 (PDT)
Message-ID: <20090503.142054.162325923.davem@davemloft.net>
References: <20090503095506.GA6177@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkundrak@v3.sk, jeff@garzik.org,
	akpm@linux-foundation.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754270AbZECVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 17:20:59 -0400
In-Reply-To: <20090503095506.GA6177@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 3 May 2009 11:55:06 +0200

> Spotted a tiny ugliness in a recently posted patch. This patch cuts it out.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied to net-next-2.6, thanks.
