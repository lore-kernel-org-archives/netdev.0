From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Supporting C45 PHY without ID registers
Date: Tue, 28 Jun 2016 02:56:18 +0200
Message-ID: <20160628005618.GC26597@lunn.ch>
References: <CAAtXAHdfL07C+p-FcafHL5s0Noqh4Br1VP6dcyBr89wWidvsJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58847 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888AbcF1A4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 20:56:20 -0400
Content-Disposition: inline
In-Reply-To: <CAAtXAHdfL07C+p-FcafHL5s0Noqh4Br1VP6dcyBr89wWidvsJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 04:36:20PM -0700, Moritz Fischer wrote:
> Hi all,
> 
> I have a 10GigE PHY that I'm working with that has most of it's
> functionality availabile via MDIO
> in a clause 45 compliant fashion, however the usual probe method fails
> since the id registers
> are not implemented.

Hi Moritz

Does it have any ID registers at all?

     Andrew
