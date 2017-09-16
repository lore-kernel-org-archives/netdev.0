From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Documentation: networking: fix ASCII art in switchdev.txt
Date: Sat, 16 Sep 2017 23:29:53 +0200
Message-ID: <20170916212953.GB3856@lunn.ch>
References: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Pavel Machek <pavel@ucw.cz>,
        Andreas Schwab <schwab@linux-m68k.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Scott Feldman <sfeldma@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:45036 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbdIPV36 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 16 Sep 2017 17:29:58 -0400
Content-Disposition: inline
In-Reply-To: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 16, 2017 at 01:10:06PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix ASCII art in Documentation/networking/switchdev.txt:
> 
> Change non-ASCII "spaces" to ASCII spaces.
> 
> Change 2 erroneous '+' characters in ASCII art to '-' (at the '*'
> characters below):
> 
> line 32:
>                      +--+----+----+----+-*--+----+---+  +-----+-----+
> line 41:
>                      +--------------+---*------------+
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

A much more readable patch. Thanks

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
