From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: make local functions static
Date: Mon, 18 Mar 2013 15:33:42 +0000
Message-ID: <1363620822.2602.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130316095751.33087a2b@nehalam.linuxnetplumber.net>
	 <20130317.142653.1414523995890573030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6947 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3CRPdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 11:33:50 -0400
In-Reply-To: <20130317.142653.1414523995890573030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 14:26 -0400, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat, 16 Mar 2013 09:57:51 -0700
> 
> > Trivial sparse detected functions that should be static.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Applied, thanks Stephen.

Thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
