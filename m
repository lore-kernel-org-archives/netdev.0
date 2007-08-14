From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/13] cxgb3 - log adapter derial number
Date: Tue, 14 Aug 2007 01:45:38 -0400
Message-ID: <46C14182.1030205@garzik.org>
References: <20070811063010.8148.57462.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37808 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S942610AbXHNFpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:45:40 -0400
In-Reply-To: <20070811063010.8148.57462.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Log HW serial number when cxgb3 module is loaded.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/common.h     |    2 ++
>  drivers/net/cxgb3/cxgb3_main.c |    6 ++++--
>  drivers/net/cxgb3/t3_hw.c      |    3 ++-
>  3 files changed, 8 insertions(+), 3 deletions(-)

ACK patches 6-8


