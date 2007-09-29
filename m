From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Sat, 29 Sep 2007 01:14:58 -0400
Message-ID: <46FDDF52.1020607@pobox.com>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl> <46E8B56E.7060705@pobox.com> <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl> <20070913151452.GB29665@linux-mips.org> <46E95C7F.1050302@pobox.com> <Pine.LNX.4.64N.0709141135290.1926@blysk.ds.pg.gda.pl> <46F1F2CE.7020300@pobox.com> <Pine.LNX.4.64N.0709201354320.30788@blysk.ds.pg.gda.pl> <46F2A779.2040904@pobox.com> <Pine.LNX.4.64N.0709201829290.30788@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36085 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbXI2FPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:15:34 -0400
In-Reply-To: <Pine.LNX.4.64N.0709201829290.30788@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  Remove typedefs, volatiles and convert kmalloc()/memset() pairs to
> kcalloc().  Also reformat the surrounding clutter.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> On Thu, 20 Sep 2007, Jeff Garzik wrote:
> 
>> Remove the "linux-" prefix.
> 
>  Hmm, it looks like a bad application of `sed' by myself.  Sorry for the 
> noise.
> 
>   Maciej

applied


