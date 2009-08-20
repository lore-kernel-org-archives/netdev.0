From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH V2] lib/vsprintf.c: Add struct sockaddr *
 "%pN<foo>" output
Date: Wed, 19 Aug 2009 21:29:41 -0700 (PDT)
Message-ID: <20090819.212941.235652305.davem@davemloft.net>
References: <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com>
	<1250721391.3407.103.camel@Joe-Laptop.home>
	<1250742246.2000.4.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, jens@mcbone.net, brian.haley@hp.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbZHTE3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 00:29:30 -0400
In-Reply-To: <1250742246.2000.4.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 19 Aug 2009 21:24:06 -0700

> On Wed, 2009-08-19 at 15:36 -0700, Joe Perches wrote:
>> > Having a hexadecimal port number option  
>> > might be more useful.  The hexadecimal form is also used by the  
>> > kernel's RPC implementation, fwiw.
>> 
>> Easy enough.
> 
> Do you have an opinion on this style patch to lib/vsprint?
> Where does it fall on the useless <-> desirable scale?

Who me?

I'm just following this thread loosely, and just plan to review it
on a whole once things seem to quiet down and the major issues
seem to be worked out.

I really have no hard opinion on anything like this, sorry for
the lack of feedback, I simply have none :)
