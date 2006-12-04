From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 3
Date: Mon, 04 Dec 2006 18:42:43 -0500
Message-ID: <4574B273.2030406@pobox.com>
References: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39560 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967837AbWLDXmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:42:45 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Victor wrote:
> A minor fix to the Atmel AT91RM9200 Ethernet driver.
> 
> 1. Use dev_alloc_skb() instead of alloc_skb().
> 2. It is not necessary to adjust skb->len manually.
> 
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>

ACK patch content


