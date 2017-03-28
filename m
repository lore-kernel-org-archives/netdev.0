From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 16:19:01 +1100
Message-ID: <1490678341.3177.103.camel@kernel.crashing.org>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
         <1490668137.3177.98.camel@kernel.crashing.org>
         <1490669734.3177.100.camel@au1.ibm.com>
         <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
         <1490678238.3177.102.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <rmk+kernel@armlinux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48870 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751633AbdC1FTg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 01:19:36 -0400
In-Reply-To: <1490678238.3177.102.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 16:17 +1100, Benjamin Herrenschmidt wrote:
> Hence my question ... how "standard" is the re-use of the LPA bits
> for these alternate meanings in 1000bT and should we update genphy
> to perform that decoding ?

And btw, I'm happy to provide patches if we agree on the approach :-)

Cheers,
Ben.
