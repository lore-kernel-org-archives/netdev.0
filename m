From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: Fix IP1000 config dependencies.
Date: Wed, 31 Oct 2007 21:04:01 +0100
Message-ID: <20071031200400.GA12775@electric-eye.fr.zoreil.com>
References: <20071030.205905.75927379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50690 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754067AbXJaULK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 16:11:10 -0400
Content-Disposition: inline
In-Reply-To: <20071030.205905.75927379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
[...]
> Noticed during some randconfig runs.
> 
> [NET]: IP1000 driver needs MII.

It is fixed as of bbd82f956e0db6190b16a8a00d3ed5d979f488e8.

-- 
Ueimor
