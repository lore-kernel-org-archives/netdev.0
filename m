From: Meelis Roos <mroos@linux.ee>
Subject: Re: [git patches] net driver fixes
Date: Thu, 27 Dec 2007 13:28:55 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0712271327030.20202@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:40338 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbXL0L25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 06:28:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

JG> A couple [minorly] notable wireless bug fixes, and plenty of viro fixes
JG> for obscure issues :)

What about the tulip NAPI fix from Stephen Hemminger? Without this, my 
tulip is hosed easily.

The thread where I reported it was "Badness at net/core/dev.c:2199", 
around Dec 16.

-- 
Meelis Roos (mroos@linux.ee)
