From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: micrel: add KSZ8795 ethernet switch
Date: Fri, 20 Jan 2017 15:17:28 +0100
Message-ID: <20170120141728.GA13115@lunn.ch>
References: <20170120125049.121307-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39380 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752151AbdATORb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 09:17:31 -0500
Content-Disposition: inline
In-Reply-To: <20170120125049.121307-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 01:50:49PM +0100, Sean Nyekjaer wrote:
> This ethernet switch have unfortunately the same phy id as KSZ8051.

Hi Sean

Please could you explain some more. You are adding PHY support here,
not switch support. So is this to enable the PHY driver for the PHYs
embedded in the switch?

	 Andrew
