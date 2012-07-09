From: Timur Tabi <b04825@freescale.com>
Subject: Re: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the
 indicator register
Date: Mon, 9 Jul 2012 16:19:07 -0500
Message-ID: <4FFB4ACB.2000304@freescale.com>
References: <1341357381-10861-1-git-send-email-timur@freescale.com> <20120708.235926.1117975937932919247.davem@davemloft.net> <4FFAEB44.2030600@freescale.com> <20120709.141714.1072959067688919521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <afleming@freescale.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:8560
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab2GIVTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:19:11 -0400
In-Reply-To: <20120709.141714.1072959067688919521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Do you really mean that:
> 
> 	foo = function(arg1,
> 		arg2);
> 
> doesn't look like complete and utter shit to you?

It doesn't bother me, but I'll change it.

-- 
Timur Tabi
Linux kernel developer at Freescale
