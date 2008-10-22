From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Wed, 22 Oct 2008 07:03:00 -0400
Message-ID: <48FF0864.9060306@pobox.com>
References: <20081020190922.7dd6510a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbYJVLDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 07:03:04 -0400
In-Reply-To: <20081020190922.7dd6510a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Add support for recycling tx buffers into receive buffers.
> This is experimental at this point.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Since the merge window appears to have past, this can wait until 2.6.29
> 

for what it's worth...  I am following DaveM's lead, and waiting until 
net-next opens to start taking patches for 2.6.29.  He wants us to focus 
on bug fixing for now.

So, please resend once the merge window opens... thanks.

	Jeff




