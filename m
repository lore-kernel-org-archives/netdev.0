From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/11] add NAPI support to sb1250-mac.c
Date: Fri, 27 Apr 2007 20:32:07 -0400
Message-ID: <46329607.4060300@garzik.org>
References: <200704260723.l3Q7NNAV023841@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmason@upwardaccess.com, mason@broadcom.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757967AbXD1AcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:32:09 -0400
In-Reply-To: <200704260723.l3Q7NNAV023841@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Mark Mason <mmason@upwardaccess.com>
> 
> Patch to add NAPI support to sb1250-mac.c (rev 2).  This patch differs from
> the last in that the NAPI support isn't marked as experimental, nor is it
> configurable (ie.  once applied - NAPI is enabled all the time).  This was
> based on feedback from Ralf and others.
> 
> Signed-off-by: Mark Mason <mason@broadcom.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sb1250-mac.c |  273 ++++++++++++++++++++++++-------------
>  1 file changed, 180 insertions(+), 93 deletions(-)

applied


