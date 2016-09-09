From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] macsec: set network devtype
Date: Fri, 9 Sep 2016 17:54:36 +0200
Message-ID: <20160909155436.GB16002@bistromath.localdomain>
References: <20160907140732.396bc2cf@xeon-e3>
 <20160908.172407.273322865763730537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53446 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbcIIPyj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 11:54:39 -0400
Content-Disposition: inline
In-Reply-To: <20160908.172407.273322865763730537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-08, 17:24:07 -0700, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 7 Sep 2016 14:07:32 -0700
> 
> > The netdevice type structure for macsec was being defined but never used.
> > To set the network device type the macro SET_NETDEV_DEVTYPE must be called.
> > Compile tested only, I don't use macsec.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Sabrina, please review.
> 
> Thanks.

Sorry for the delay. LGTM:

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
