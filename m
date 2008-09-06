From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Channel bonding with e1000
Date: Sat, 06 Sep 2008 10:53:44 +0200
Message-ID: <48C24518.2090500@aei.mpg.de>
References: <48C0EF8A.9070103@aei.mpg.de> <20080905213606.0b4e246a.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:32924 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbYIFIxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2008 04:53:50 -0400
In-Reply-To: <20080905213606.0b4e246a.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Bill Fink wrote:
> Also check the respective PCI buses of the onboard NICs versus the
> addon NICs.  If one is PCI versus PCI-X or PCI-E, or are different
> speeds or bus widths, this can obviously significantly impact
> performance, especially when doing bonding.

I need to go back to Supermicro's manual for that one. The add-on ones
are definitely PCIe.

> 
> Of course nothing beats some quick performance tests to determine
> which is the better performing combination.
> 

Wisely put :)

Thanks for the input so far. We will start some testing sooner rather
than later to get more out of our file servers!

Cheers

Carsten
