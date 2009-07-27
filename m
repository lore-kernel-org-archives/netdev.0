From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 09/12] netxen: fix skb alloc size for legacy
 firmware
Date: Mon, 27 Jul 2009 10:38:25 -0700 (PDT)
Message-ID: <20090727.103825.115613529.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-10-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753885AbZG0RiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:38:18 -0400
In-Reply-To: <1248674867-18821-10-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:44 -0700

> Request 1532 bytes skb data size for NX3031. NX2031 firmware
> needs 1760 sized buffers.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
