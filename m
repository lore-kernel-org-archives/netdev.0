From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Thu, 13 Sep 2007 11:51:27 -0400
Message-ID: <46E95C7F.1050302@pobox.com>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl> <46E8B56E.7060705@pobox.com> <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl> <20070913151452.GB29665@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54833 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbXIMPvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 11:51:43 -0400
In-Reply-To: <20070913151452.GB29665@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> On Thu, Sep 13, 2007 at 03:13:06PM +0100, Maciej W. Rozycki wrote:
> 
>>  Hmm, works fine with linux-2.6.git#master.  I do not recall any recent 
>> activity with this driver -- I wonder what the difference is.  Let me 
>> see...
> 
> Hmm...  HEAD du jour has no differences for the sb1250-mac between lmo
> and kernel.org.

Net driver patches should apply on top of netdev-2.6.git#upstream, which 
is where changes to net drivers are queued for the next release.

The closer we get to the merge window, the greater the diff between 
netdev-2.6.git#upstream and linux-2.6.git#master, so 
linux-2.6.git#master is not a useful comparison.

	Jeff



