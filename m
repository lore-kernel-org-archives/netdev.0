From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH V2] lib/vsprintf.c: Add struct sockaddr *
 "%pN<foo>" output
Date: Wed, 19 Aug 2009 21:24:06 -0700
Message-ID: <1250742246.2000.4.camel@Joe-Laptop.home>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
	 <1250349894.4620.5.camel@Joe-Laptop.home>
	 <1250395818.4625.15.camel@Joe-Laptop.home>
	 <2D3306C4-4DF4-4E3E-BBC2-2032058FA673@oracle.com>
	 <1250714657.3407.77.camel@Joe-Laptop.home>
	 <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com>
	 <1250721391.3407.103.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chuck Lever <chuck.lever@oracle.com>, jens@mcbone.net,
	brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1144 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbZHTEYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 00:24:18 -0400
In-Reply-To: <1250721391.3407.103.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 15:36 -0700, Joe Perches wrote:
> > Having a hexadecimal port number option  
> > might be more useful.  The hexadecimal form is also used by the  
> > kernel's RPC implementation, fwiw.
> 
> Easy enough.

Do you have an opinion on this style patch to lib/vsprint?
Where does it fall on the useless <-> desirable scale?

