From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/13] cxgb3 - SGE doorbell overflow warning
Date: Tue, 14 Aug 2007 01:42:51 -0400
Message-ID: <46C140DB.7030909@garzik.org>
References: <20070811062944.8058.38057.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46727 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941225AbXHNFmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:42:53 -0400
In-Reply-To: <20070811062944.8058.38057.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Log doorbell Fifo overflow
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/regs.h |    8 ++++++++
>  drivers/net/cxgb3/sge.c  |    4 ++++
>  2 files changed, 12 insertions(+), 0 deletions(-)

ACK, but not applied since patch #2 was not applied


