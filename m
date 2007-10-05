From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Fri, 05 Oct 2007 13:56:00 -0400
Message-ID: <47067AB0.4060607@garzik.org>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47878 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757912AbXJER4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 13:56:03 -0400
In-Reply-To: <20071004183843.31540.23710.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> A small bug crawled in the -DDEBUG enabled code. Fix this to
> properly call the backreference device name.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/hw.h     |    2 +-
>  drivers/net/e1000e/netdev.c |    4 +---
>  2 files changed, 2 insertions(+), 4 deletions(-)

applied


