From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gianfar needs crc32 lib dependency
Date: Thu, 19 Apr 2007 15:03:22 -0400
Message-ID: <4627BCFA.6050207@garzik.org>
References: <20070412175706.GA12664@blade.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galak@kernel.crashing.org,
	afleming@freescale.com, sshtylyov@ru.mvista.com
To: Dave Jiang <djiang@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59964 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766928AbXDSTD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 15:03:26 -0400
In-Reply-To: <20070412175706.GA12664@blade.az.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jiang wrote:
> Gianfar needs crc32 to be selected to compile. 
> 
> Signed-off-by: Dave Jiang <djiang@mvista.com>
> 
> --
>  drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied


