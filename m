From: jamal <hadi@cyberus.ca>
Subject: Post Network dev questions to netdev Please WAS(Re: [patch 4/10]
	s390: network driver.
Date: 06 Dec 2004 06:01:18 -0500
Message-ID: <1102330877.1042.2187.camel@jzny.localdomain>
References: <OFAF17275D.316533A1-ONC1256F5C.0026AFAD-C1256F5C.002877C1@de.ibm.com>
	 <Pine.LNX.4.61.0412050605550.21671@hibernia.jakma.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>, jgarzik@pobox.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.61.0412050605550.21671@hibernia.jakma.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 01:25, Paul Jakma wrote:

> 
> This has always been (AFAIK) the behaviour yes. We started getting 
> reports of the new queuing behaviour with, iirc, a version of Intel's 
> e100 driver for 2.4.2x, which was later changed back to the old 
> behaviour. However now that the queue behaviour is apparently the 
> mandated behaviour we really need to work out what to do about the 
> sending-long-stale packets problem.
> 

I missed the beginings of this thread. Seems some patch was posted
on lkml which started this discussion. I am pretty sure what the lkml
FAQ says is to post on netdev. Ok, If you insist posting on lkml
(because that the way to glory, good fortune and fame), then please have
the courtesy to post to netdev.  

Now lets see if we can help. Followups only on netdev.

cheers,
jamal
