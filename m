From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] atlx: make strings const
Date: Wed, 08 Sep 2010 15:58:11 -0700
Message-ID: <1283986691.24986.31.camel@Joe-Laptop>
References: <20100908151836.3c40cc81@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1536 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756597Ab0IHW6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 18:58:12 -0400
In-Reply-To: <20100908151836.3c40cc81@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-08 at 15:18 -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Chris Snook <chris.snook@gmail.com>
> 

Shouldn't that be done with all of the global
static char foo[] = "bar"; declarations?



