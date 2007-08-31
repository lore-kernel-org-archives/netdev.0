From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/11] cxgb3 - Update internal memory management
Date: Fri, 31 Aug 2007 09:37:52 -0400
Message-ID: <46D819B0.1070606@garzik.org>
References: <20070822034941.9387.79621.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58566 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965056AbXHaNhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:37:54 -0400
In-Reply-To: <20070822034941.9387.79621.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Set PM1 internal memory to round robin mode
> It balances access to this internal memory for multiport adapters.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/regs.h  |    2 ++
>  drivers/net/cxgb3/t3_hw.c |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)

applied patches 1-8


