From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: DSA: Marvell mv88e6171 switch driver
Date: Sat, 13 Sep 2014 02:12:46 +0200
Message-ID: <20140913001246.GB11435@lunn.ch>
References: <1410559124-10495-1-git-send-email-andrew@lunn.ch>
 <541370DD.7090309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, Claudio Leite <leitec@staticky.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48900 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041AbaIMATS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 20:19:18 -0400
Content-Disposition: inline
In-Reply-To: <541370DD.7090309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 03:17:01PM -0700, Florian Fainelli wrote:
> Hi Andrew,
> 
> On 09/12/2014 02:58 PM, Andrew Lunn wrote:
> > This is the Marvell driver with some cleanups by Claudio Leite
> > and myself.
> 
> Looks good to me, this will slightly conflict with the patch for the
> tag_protocol field [1], other than that, good to see this driver
> submitted! Thanks!

Hi Florian

How do you want to handle this conflict?

      Andrew
