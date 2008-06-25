From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27] cxgb3 - add missing adapter type for RDMA
Date: Tue, 24 Jun 2008 23:09:24 -0400
Message-ID: <4861B6E4.3040803@garzik.org>
References: <20080623180259.12447.52386.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48110 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754094AbYFYDJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 23:09:28 -0400
In-Reply-To: <20080623180259.12447.52386.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> T3C added support is now reflected to the RDMA driver.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_offload.c |   21 ++++++++++++++++++++-
>  drivers/net/cxgb3/t3cdev.h        |    3 ++-
>  2 files changed, 22 insertions(+), 2 deletions(-)

applied


