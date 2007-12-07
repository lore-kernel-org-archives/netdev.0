From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] cxgb3 - Parity initialization for T3C adapters
Date: Fri, 07 Dec 2007 15:02:50 -0500
Message-ID: <4759A6EA.1050106@garzik.org>
References: <20071205181527.22106.73134.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40120 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756826AbXLGUCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:02:52 -0500
In-Reply-To: <20071205181527.22106.73134.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Add parity initialization for T3C adapters.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/adapter.h       |    1 
>  drivers/net/cxgb3/cxgb3_main.c    |   82 ++++++++++++
>  drivers/net/cxgb3/cxgb3_offload.c |   15 ++
>  drivers/net/cxgb3/regs.h          |  248 +++++++++++++++++++++++++++++++++++++
>  drivers/net/cxgb3/sge.c           |   24 +++-
>  drivers/net/cxgb3/t3_hw.c         |  131 +++++++++++++++++---
>  6 files changed, 472 insertions(+), 29 deletions(-)

dropped patches 2-3, did not apply


