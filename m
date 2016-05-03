From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Tue, 3 May 2016 17:36:59 +0200
Message-ID: <20160503153659.GA29815@lunn.ch>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com>
 <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Amr Bekhit <amrbekhit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56170 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932884AbcECPhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:37:03 -0400
Content-Disposition: inline
In-Reply-To: <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Any ideas as to why I can't get any packets out? Is there a way for me
> to test whether there is an issue between the MAC and PHY?

Does it perform auto-negotiate? If it does, the PHY to the cable is
probably O.K.

Have you checked the status bits. Loopback, Power down, Isolate?

     Andrew
