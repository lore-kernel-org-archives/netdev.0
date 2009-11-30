From: David Miller <davem@davemloft.net>
Subject: Re: dmfe/tulip device id overlap
Date: Sun, 29 Nov 2009 23:07:03 -0800 (PST)
Message-ID: <20091129.230703.206229796.davem@davemloft.net>
References: <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
	<20091129.003024.245104886.davem@davemloft.net>
	<20091130065512.GA2792@jenkins.domain_not_set.invalid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@google.com, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: brandon@ifup.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752834AbZK3HG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:06:57 -0500
In-Reply-To: <20091130065512.GA2792@jenkins.domain_not_set.invalid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <brandon@ifup.org>
Date: Sun, 29 Nov 2009 22:55:12 -0800

> Thus, the patch only lets tulip handle 0x9100 and 0x9102 if __sparc__.
> 
> Perhaps someone knows if there is a way to tell the PCI card from the
> sparc builtin machine?

We should get both cases working in one of the two drivers,
preferrably Tulip.

That's the outcome I'm trying to say is the only legitimate one.
