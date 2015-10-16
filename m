From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 01:54:08 +0200
Message-ID: <20151016235408.GB28795@lunn.ch>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
 <5621890E.8090704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42080 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJPXyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 19:54:10 -0400
Content-Disposition: inline
In-Reply-To: <5621890E.8090704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 02:32:30AM +0300, Sergei Shtylyov wrote:
> On 10/16/2015 11:49 PM, Andrew Lunn wrote:
> 
> >Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> >the bus' parent." broke finding PHY properties in the MAC device tree
> 
>    You probably forgot to run checkpatch.pl on this patch, else it
> would have complained about the commit citing style. It's <12-bit
> SHA1> ("<summary line>").

Actual, i did, and decided to ignore it. I'm quoting the regression
report, which formats it that way. However i did deliberately use the
correct format for the fixes: line, where it actually matters.

checkpatch is just a guide, not a rigid rule.

	   Andrew
