From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Fri, 22 Sep 2006 20:38:13 +0200
Message-ID: <20060922183812.GF4161@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net> <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:42117 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S964878AbWIVSiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 14:38:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922113152.02874cbc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> To get tx flow control to turn off. You need a patch (already in netdev-2.6 upstream)
> and then you can do:
> 
> 	ethtool -A eth1 autoneg off tx off

Sorry, you've lost me.  Which patch?  You're saying that turning off tx
flow control will fix the hangs I'm seeing?

-mato
