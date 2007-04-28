From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] smc911x: fix compilation breakage wjen debug is on
Date: Sat, 28 Apr 2007 11:35:03 -0400
Message-ID: <463369A7.6040103@pobox.com>
References: <20070427144209.00006694.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com, netdev@vger.kernel.org
To: Vitaly Wool <vwool@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52178 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161809AbXD1PfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:35:05 -0400
In-Reply-To: <20070427144209.00006694.vwool@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Wool wrote:
> Hello Jeff,
> 
> the patch below fixes compilation breakage of smc911x driver when ENABLE_SMC_DEBUG_PKTS equals to 1.
> 
>  smc911x.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

applied, and forwarded to stable@kernel.org


