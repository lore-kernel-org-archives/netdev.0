From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 11/11] 3C509: Remove unnecessary include of <linux/pm_legacy.h>
Date: Fri, 27 Apr 2007 20:13:43 -0400
Message-ID: <463291B7.9040102@garzik.org>
References: <200704260723.l3Q7NP9Y023850@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpjday@mindspring.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48209 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403AbXD1ANq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:13:46 -0400
In-Reply-To: <200704260723.l3Q7NP9Y023850@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Robert P. J. Day" <rpjday@mindspring.com>
> 
> Remove the apparently redundant include of <linux/pm_legacy.h>.
> 
> Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c509.c |    1 -
>  1 file changed, 1 deletion(-)

applied


