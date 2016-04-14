From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this
 into a library module
Date: Thu, 14 Apr 2016 23:32:38 +0200
Message-ID: <20160414213238.GA22846@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
 <1460591998-20598-2-git-send-email-andrew@lunn.ch>
 <874mb454b3.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57107 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbcDNVcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 17:32:48 -0400
Content-Disposition: inline
In-Reply-To: <874mb454b3.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

> I'm working on a few patches right away to factorize this and lighten up
> that part from your current refactoring of DSA.

Please take a look at the full series of 40 patches, before deciding
what you want to clean up. It is too many to post at once, so i'm
breaking them up into chunks. But that does mean some of the 'why' is
missing, which i'm trying to add back via a good description in the
cover note.

https://github.com/lunn/linux.git v5.6-rc2-net-next-dsa-probe

> Here's an example of duplicated code fixed for the 6131 PHY access code:
> 
>     http://ix.io/wJm

I've done this already.

     Andrew
