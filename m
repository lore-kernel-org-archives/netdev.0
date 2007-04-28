From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] e1000: ROUND_UP macro cleanup in drivers/net/e1000
Date: Fri, 27 Apr 2007 20:32:22 -0400
Message-ID: <46329616.3010504@garzik.org>
References: <20070427205529.21115.55629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48377 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757968AbXD1AcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:32:24 -0400
In-Reply-To: <20070427205529.21115.55629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Milind Arun Choudhary <milindchoudhary@gmail.com>
> 
> E1000_ROUNDUP macro cleanup, use ALIGN
> 
> Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000.h         |    3 ---
>  drivers/net/e1000/e1000_ethtool.c |    6 +++---
>  drivers/net/e1000/e1000_main.c    |   10 +++++-----
>  drivers/net/e1000/e1000_param.c   |    4 ++--
>  4 files changed, 10 insertions(+), 13 deletions(-)

applied this and the ixgb one


