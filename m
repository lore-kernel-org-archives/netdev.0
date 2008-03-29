From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: Fix multicast hash table handling
Date: Fri, 28 Mar 2008 21:53:38 -0400
Message-ID: <47EDA122.8060400@garzik.org>
References: <877ifmfsmu.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55089 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbYC2Bxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:53:41 -0400
In-Reply-To: <877ifmfsmu.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Korsgaard wrote:
> The loop forgot to walk the net->mc_list list, so only the first
> multicast address was programmed into the hash table.
> ---
> Jeff, I would like to get this patch in 2.6.25 if possible.

applied, signed-off-by lines would help...


