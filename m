From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 6 Apr 2011 15:19:40 -0400
Message-ID: <20110406191940.GD6825@hmsreliant.think-freely.org>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
 <1302113253.3209.126.camel@edumazet-laptop>
 <20110406183913.GB6825@hmsreliant.think-freely.org>
 <4D9CB697.3050209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34558 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756656Ab1DFTZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:25:29 -0400
Content-Disposition: inline
In-Reply-To: <4D9CB697.3050209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 02:53:11PM -0400, Brian Haley wrote:
> On 04/06/2011 02:39 PM, Neil Horman wrote: 
> > Also, do we have a macro already to see if an ipv6 address is all zeros?  I'm
> > not finding one, but I'd hate to re-invent the wheel if I'm just missing it.
> 
> ipv6_addr_any() inline in ipv6.h
> 
Ah thanks!
Neil

> -Brian
> 
