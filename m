From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 06:59:51 -0400
Message-ID: <20100408105951.GA16868@hmsreliant.think-freely.org>
References: <20100408.035049.177640912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52576 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758309Ab0DHK74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 06:59:56 -0400
Content-Disposition: inline
In-Reply-To: <20100408.035049.177640912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 03:50:49AM -0700, David Miller wrote:
> 
> This is an old topic, but looking at traces tonight I was reminded
> about it.
> 
> dhcp clients sniff every packet in the system, the reason it does this
> and the things we can do to make it not have to do so have been
> discussed before.  Actually, I don't remember where we got with
> that and if we were able to make it such that the dhcp client
> doesn't have to do this any more.  Herbert?
> 
Dave, sorry to be late to the discussion, but can you refesh us on why dhcp has
to sniff every packet?
Regards
Neil

