From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] lib/vsprintf.c: Add "%pI6c" - print pointer as
 compressed ipv6 address
Date: Sat, 29 Aug 2009 00:20:17 -0700 (PDT)
Message-ID: <20090829.002017.104929941.davem@davemloft.net>
References: <1250522309.16632.45.camel@fnki-nb00130>
	<1250548184.4488.6.camel@Joe-Laptop.home>
	<1250603336.16632.49.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chuck.lever@oracle.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: jens@mcbone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56852
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751446AbZH2HUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:20:03 -0400
In-Reply-To: <1250603336.16632.49.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <jens@mcbone.net>
Date: Tue, 18 Aug 2009 15:48:56 +0200

> On Mon, 2009-08-17 at 15:29 -0700, Joe Perches wrote:
>> Here's the modified patch with your suggestions:
>> 
> 
> Ran it through my test-cases and they all look fine.
> 
> Tested-by: Jens Rosenboom <jens@mcbone.net>
> 

Applied, thanks everyone.
