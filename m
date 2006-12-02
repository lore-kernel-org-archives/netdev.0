From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.18] declance: Support the I/O ASIC LANCE w/o TURBOchannel
Date: Sat, 02 Dec 2006 00:19:58 -0500
Message-ID: <45710CFE.5090007@pobox.com>
References: <Pine.LNX.4.64N.0611301306460.1757@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49582 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1162815AbWLBFUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 00:20:06 -0500
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0611301306460.1757@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  The onboard LANCE of I/O ASIC systems is not a TURBOchannel device, at 
> least from the software point of view.  Therefore it does not rely on any 
> kernel TURBOchannel bus services and can be supported even if support for 
> TURBOchannel has not been enabled in the configuration.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

can you (or Andrew) please resend your patches against 2.6.19?

	Jeff



