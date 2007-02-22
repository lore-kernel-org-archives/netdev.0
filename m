From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Thu, 22 Feb 2007 06:37:29 -0800 (PST)
Message-ID: <20070222.063729.74746068.davem@davemloft.net>
References: <20070222.002704.34758758.davem@davemloft.net>
	<20070222.003239.131918460.davem@davemloft.net>
	<45DDA7C3.4080301@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani@gmail.com, netdev@vger.kernel.org,
	andrea.baiocchi@uniroma1.it, francesco@net.infocom.uniroma1.it
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030215AbXBVOha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 09:37:30 -0500
In-Reply-To: <45DDA7C3.4080301@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 22 Feb 2007 09:25:07 -0500

> My patch is meant as a replacement for YeAH patch 2/2, not meant to back 
> it out.  You do still need the second hunk below.  Sorry 'bout that.
> 
> If you're going to apply YeAH patch 2/2 first, you will also need to 
> remove the declaration of tcp_limited_slow_start() in include/net/tcp.h.

I noticed that after sending out my diff and corrected it before
pushing to tcp-2.6, thanks :-)
