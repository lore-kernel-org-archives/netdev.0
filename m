From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/7] cxgb3 - Fix direct XAUI support
Date: Mon, 28 May 2007 18:39:02 -0400
Message-ID: <465B5A06.8030402@garzik.org>
References: <20070526225958.12133.84586.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbXE1WjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 18:39:04 -0400
In-Reply-To: <20070526225958.12133.84586.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Check all lanes for link status on direct XAUI cards.
> Don't assume that direct XAUI always uses XGMAC 1.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/ael1002.c |   10 ++++++++--
>  drivers/net/cxgb3/regs.h    |    2 ++
>  2 files changed, 10 insertions(+), 2 deletions(-)

ACK


