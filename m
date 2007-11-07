From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Wed, 07 Nov 2007 16:35:04 +0200
Message-ID: <1194446104.2987.234.camel@localhost.localdomain>
References: <20071106142558.GC1666@ff.dom.local>
	 <1194360226.4444.39.camel@localhost>
	 <1194368416.2987.218.camel@localhost.localdomain>
	 <20071107.012220.17723288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jarkao2@o2.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:43255 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758275AbXKGOhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:37:37 -0500
In-Reply-To: <20071107.012220.17723288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-11-07 at 01:22 -0800, David Miller wrote:
> I've grown impatient and done the work for you :-)  I've applied
> the patch below to my tree, thank you!
> 
> If someone wants to send me the ffs() thing relative to this,
> I'd appreciate it.  Thanks again!

Thanks again for making the patch and applying. I've just tested it and
it works like a charm.

Now moving on to the ffs() thing. I will send the patch later if it
works.

Cheers,
Radu


