From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3 2.6.27 RESEND] cxgb3 - Fix dma mapping error path
Date: Thu, 22 May 2008 07:09:00 -0400
Message-ID: <4835544C.2010005@garzik.org>
References: <20080522015616.25335.31806.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48261 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbYEVLJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:09:05 -0400
In-Reply-To: <20080522015616.25335.31806.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Take potential dma mapping errors in account.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/sge.c |   53 ++++++++++++++++++++++++++++++++++++-----------
>  1 files changed, 41 insertions(+), 12 deletions(-)

applied 1-3


