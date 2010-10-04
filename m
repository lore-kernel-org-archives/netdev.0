From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: add multiple RX queue support
Date: Sun, 03 Oct 2010 22:12:39 -0700 (PDT)
Message-ID: <20101003.221239.179930221.davem@davemloft.net>
References: <20101001104133.GA17206@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52571
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751738Ab0JDFMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:12:18 -0400
In-Reply-To: <20101001104133.GA17206@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 1 Oct 2010 16:11:33 +0530

> Dave, incorporated your comment to discover the num of supported MSIx vectors
> dynamically; thanks.
> 
> This patch adds multiple RX queue support to be2net. There are
> upto 4 extra rx-queues per port into which TCP/UDP traffic can be hashed into.
> Some of the ethtool stats are now displayed on a per queue basis.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Looks good, applied, thanks.
