From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Marvell 88E609x switch?
Date: Wed, 25 Feb 2009 07:31:45 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0902250727520.28163@ask.diku.dk>
References: <49A49C06.90908@mlbassoc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:41525 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbZBYGbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 01:31:50 -0500
In-Reply-To: <49A49C06.90908@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Feb 2009, Gary Thomas wrote:

> Is there support for this device anywhere?  In particular,
> the M88E6095 switch.

I have written a driver for the M88E6095F and M88E6097F switch, but only 
for an embedded 2.4.20 kernel device.  I have written it from scratch, so 
its not covered by Marvell license.  Although lately different marvell DSA 
support was added to kernel 2.6.

Whats you usage?

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
