From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Adding vlan to DSA port causes lockdep splat
Date: Tue, 21 Feb 2017 15:03:03 +0100
Message-ID: <20170221140303.GD8852@lunn.ch>
References: <CAJGZr0JNsL3HG_CUs_jhavYJ5Z6Z6S-bhmE4sONkk++uEZL7nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47060 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753336AbdBUODI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 09:03:08 -0500
Content-Disposition: inline
In-Reply-To: <CAJGZr0JNsL3HG_CUs_jhavYJ5Z6Z6S-bhmE4sONkk++uEZL7nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 11:38:24AM +0300, Maxim Uvarov wrote:
> Is there any progress on subj issue?
> 
> I see it was investigated here:
> https://www.spinics.net/lists/netdev/msg361434.html

Hi Maxim

Nobody made further investigations. And since i don't see it in my
tests, i've never been annoyed enough to go try find a fix.

       Andrew
