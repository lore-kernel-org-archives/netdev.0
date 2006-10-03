From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 20:39:49 +0200
Message-ID: <20061003183948.GO14180@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net> <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain> <20060922183812.GF4161@dezo.moloch.sk> <20060922115008.5060c599@localhost.localdomain> <20061003182119.GM14180@dezo.moloch.sk> <20061003113538.4c3fe57d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:13198 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S1030468AbWJCSju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:39:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061003113538.4c3fe57d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> On Tue, 3 Oct 2006 20:21:20 +0200
> Martin Lucina <mato@kotelna.sk> wrote:
> 
> > Hi Stephen,
> > 
> > I'm still getting tx timeouts even after applying the patch you sent me
> > and forcing tx flow control off:
> 
> What speed and duplex are you using?

1000 Mbps, full duplex

> What MTU are you using.

1500

-mato
