From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH #2] sb1250: use netdev_alloc_skb
Date: Thu, 22 May 2008 06:21:24 -0400
Message-ID: <48354924.1030603@pobox.com>
References: <Pine.LNX.4.55.0805180442280.10067@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59284 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935137AbYEVKV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:21:27 -0400
In-Reply-To: <Pine.LNX.4.55.0805180442280.10067@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej W. Rozycki wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> 
>  Use netdev_alloc_skb.  This sets skb->dev and allows arch specific
> allocation.  Also simplify and cleanup the alignment code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  I have not received any ack or nack on this one.  Jeff, please apply.

applied


