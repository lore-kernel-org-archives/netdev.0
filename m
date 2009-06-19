From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/2] af_iucv patches for linux-2.6.31
Date: Fri, 19 Jun 2009 09:04:26 +0200
Message-ID: <20090619090426.19969a0b@skybase>
References: <20090618075446.890351000@linux.vnet.ibm.com>
	<20090618.013410.04304670.davem@davemloft.net>
	<1245329094.14954.38.camel@braunu-laptop>
	<20090618.111957.70533925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, ursula.braun@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	heiko.carstens@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:43896 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbZFSHEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:04:36 -0400
In-Reply-To: <20090618.111957.70533925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, 18 Jun 2009 11:19:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Thu, 18 Jun 2009 14:44:54 +0200
> 
> > sorry, I did a git pull on linux-2.6.git first, and the af_iucv patches
> > applied cleanly on my system.
> 
> It couldn't have applied to Linus's tree because all the IUCV
> bits you submitted to me for 2.6.31 are in his tree and that is
> what created the conflicts.

Now I am confused. I just tested the two patches Uschi sent with todays
upstream tree. The patches apply fine. Where is the problem, wrong tree?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

