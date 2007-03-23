From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/7] skge: ignore unused error interrupts
Date: Fri, 23 Mar 2007 01:58:35 -0400
Message-ID: <46036C8B.6070309@pobox.com>
References: <20070316210125.324052637@linux-foundation.org> <20070316210156.026996576@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60565 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933675AbXCWF6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:58:36 -0400
In-Reply-To: <20070316210156.026996576@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The following hardware error bits only show up on Genesis chipset
> and are handled elsewhere, so they can be masked off.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/skge.h |    1 -
>  1 file changed, 1 deletion(-)

applied 4-7


