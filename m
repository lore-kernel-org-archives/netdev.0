From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC v2 23/32] net: dsa: bcm_sf2: make it a real platform
 driver
Date: Thu, 3 Mar 2016 20:12:14 +0100
Message-ID: <20160303191214.GP15541@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-24-git-send-email-andrew@lunn.ch>
 <56D8835F.4040607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48980 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbcCCTMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 14:12:17 -0500
Content-Disposition: inline
In-Reply-To: <56D8835F.4040607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As I mentioned before, this is a no go for the SF2 platforms out there
> which are using the old DSA binding

Hi Florian

This is a clear bug and needs fixing. The old binding will be kept
working.

Lets get the big picture agreed, and then i will come back and fix
this.

	Andrew
