From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] cxgb - fix T2 GSO
Date: Sat, 01 Dec 2007 16:34:03 -0500
Message-ID: <4751D34B.9030908@garzik.org>
References: <20071127213009.804.49490.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greearb@candelatech.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32876 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbXLAVeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:34:05 -0500
In-Reply-To: <20071127213009.804.49490.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> The patch ensures that a GSO skb has enough headroom
> to push an encapsulating cpl_tx_pkt_lso header.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---

applied 1-3


