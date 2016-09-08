From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Minimum MTU Mess
Date: Thu, 8 Sep 2016 03:24:13 +0200
Message-ID: <20160908012413.GA12745@lunn.ch>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907203112.GA26445@lunn.ch>
 <20160907234306.GY33916@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38169 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752167AbcIHBYS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 21:24:18 -0400
Content-Disposition: inline
In-Reply-To: <20160907234306.GY33916@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is definitely going to require a few passes... (Working my way
> through every driver with an ndo_change_mtu wired up right now to
> see just how crazy this might get).

It might be something Coccinelle can help you with. Try describing the
transformation you want to do, to their mailing list, and they might
come up with a script for you.

     Andrew
