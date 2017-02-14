From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net:dsa:mv88e6xxx: use watchdog ops for 6097
 chip
Date: Tue, 14 Feb 2017 16:46:18 +0100
Message-ID: <20170214154618.GB15553@lunn.ch>
References: <1487068170-18923-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39558 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753272AbdBNPqV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 10:46:21 -0500
Content-Disposition: inline
In-Reply-To: <1487068170-18923-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 11:29:30AM +0100, Volodymyr Bendiuga wrote:
> mv88e6097 chip requires watchdog_ops to be set.

Hi Volodymyr

Upps. Thanks for the fix.
 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
