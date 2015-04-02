From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 01/12] net: dsa: mv88e6131: Use common initialization
 functions
Date: Thu, 2 Apr 2015 03:51:56 +0200
Message-ID: <20150402015156.GA11760@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
 <1427937719-11630-2-git-send-email-andrew@lunn.ch>
 <551C9DD7.7040505@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35788 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbbDBBzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:55:51 -0400
Content-Disposition: inline
In-Reply-To: <551C9DD7.7040505@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2015 at 06:39:35PM -0700, Guenter Roeck wrote:
> On 04/01/2015 06:21 PM, Andrew Lunn wrote:
> >From: Guenter Roeck <linux@roeck-us.net>
> >
> >Common initialization functions will be needed to enable
> >HW bridging support.
> >
> >Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> >Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
> Hi Andrew,
> 
> No idea how David handles this, but I would have expected to see your
> Signed-off-by: here to reflect the submit path.

Humm, yes.

David, do you want a respin with added Signed-off-by from me for the
patches Guenter authored?

	Andrew
