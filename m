From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] af_iucv patches for linux-2.6.31
Date: Fri, 19 Jun 2009 00:11:03 -0700 (PDT)
Message-ID: <20090619.001103.186026755.davem@davemloft.net>
References: <1245329094.14954.38.camel@braunu-laptop>
	<20090618.111957.70533925.davem@davemloft.net>
	<20090619090426.19969a0b@skybase>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, ursula.braun@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	heiko.carstens@de.ibm.com
To: schwidefsky@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37456
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751615AbZFSHK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:10:59 -0400
In-Reply-To: <20090619090426.19969a0b@skybase>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Fri, 19 Jun 2009 09:04:26 +0200

> Hi David,
> 
> On Thu, 18 Jun 2009 11:19:57 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
>> Date: Thu, 18 Jun 2009 14:44:54 +0200
>> 
>> > sorry, I did a git pull on linux-2.6.git first, and the af_iucv patches
>> > applied cleanly on my system.
>> 
>> It couldn't have applied to Linus's tree because all the IUCV
>> bits you submitted to me for 2.6.31 are in his tree and that is
>> what created the conflicts.
> 
> Now I am confused. I just tested the two patches Uschi sent with todays
> upstream tree. The patches apply fine. Where is the problem, wrong tree?

Weird, I just retried and they do apply cleanly.

I have no idea what happened, sorry.

They are in my tree now, thanks.
