From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Fwd: Network Core
Date: Wed, 5 Nov 2008 19:38:17 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0811051927310.7000@ask.diku.dk>
References: <530d01580811050939q1c1dc52fra6fc2078d86d36e@mail.gmail.com>
 <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: "Diego ." <eljedi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42974 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757508AbYKESiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 13:38:20 -0500
In-Reply-To: <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Nov 2008, Diego . wrote:

> I'm a kernel newbie.
>
> I'm trying to figure how hard it will be build some SMA protocol
> inside linux kernel. But i coud'nt  find any information about linux
> network layer/core. I started looking at source code inside net/ dir
> before asking here.
>
> Could you point me to somewhere i can find some info about howto to
> port/create a network protocol to/on linux? ( i mean, some basic info
> like the one we can find with the fs layer. I'm not asking about a
> magic tutorial about how to port my protocol ). Or some basic network
> layer info.

I'll recommend the following book:

  "Understanding Linux Network Internals"
  Publisher: O'Reilly
  Author: Christian Benvenuti

Its from 2006 and is about 2.6.x kernel.  I mainly used it when writing a 
Ethernet DSA protocol handler, although for a 2.4.20 kernel on an embedded 
system.  Stephen Hemminger browsed through the book, at my house, and 
noted that it was not quite up-to-date, but close enough.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
