From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH-2.4] e100: incorrect use of "&&" instead of "&"
Date: Tue, 28 Nov 2006 02:05:38 +0100
Message-ID: <20061128010538.GA22370@1wt.eu>
References: <20061125213517.GA5965@1wt.eu> <456B20F6.8010009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, davem@davemloft.net, linux-net@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:63492 "EHLO 1wt.eu")
	by vger.kernel.org with ESMTP id S935003AbWK1BF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 20:05:59 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <456B20F6.8010009@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

On Mon, Nov 27, 2006 at 09:31:34AM -0800, Auke Kok wrote:
> Willy Tarreau wrote:
> >Hi guys,
> >
> >I'm about to apply this fix to 2.4. 2.6 is not affected.
> >Do you have any objection ?
> 
> Willy,
> 
> you didn't CC netdev. linux-net is a users list, you didn't CC the 
> maintainers of the driver. Please do this. We're more than happy to help, 
> even for 2.4 kernels.

I'm really sorry, as I usually use netdev and not linux-net. I don't know
why I used this one in the first step. There might have been some fog
inside my head.

BTW, there's no clear maintainer identified for e100. At best I can find
"linux.nics@intel.com" in the file, without any freshness info. Is that
still OK or do you want to update the MAINTAINERS file ?

> Patch looks good, please apply.
> 
> Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Done, thanks !

Willy

