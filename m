From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Thu, 27 Dec 2007 06:40:33 -0500
Message-ID: <47738F31.20304@garzik.org>
References: <Pine.SOC.4.64.0712271327030.20202@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56130 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbXL0Lkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 06:40:36 -0500
In-Reply-To: <Pine.SOC.4.64.0712271327030.20202@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meelis Roos wrote:
> JG> A couple [minorly] notable wireless bug fixes, and plenty of viro fixes
> JG> for obscure issues :)
> 
> What about the tulip NAPI fix from Stephen Hemminger? Without this, my 
> tulip is hosed easily.
> 
> The thread where I reported it was "Badness at net/core/dev.c:2199", 
> around Dec 16.

That's going up in the first post-Xmas batch.

	Jeff



