From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 10/16] mii: Simplify mii_resolve_flowctrl_fdx()
Date: Thu, 30 Apr 2009 09:18:26 +0100
Message-ID: <OF74397B04.7020B4AE-ON802575A8.002D7699-802575A8.002DA009@smsc.com>
References: <1241028905.3246.55.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1042 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751306AbZD3ISt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 04:18:49 -0400
In-Reply-To: <1241028905.3246.55.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote on 29/04/2009 19:15:05:

> This is a shorter and more comprehensible formulation of the
> conditions for each flow control mode.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Thanks Ben, much simpler than my version!

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
