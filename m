From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Wed, 28 Nov 2007 14:50:37 -0500
Message-ID: <474DC68D.9020003@roinet.com>
References: <20071108181741.8648.61629.stgit@localhost.localdomain> <474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com> <474DC0F3.8070604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	miltonm@bga.com, e1000-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:40865
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbXK1Tu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 14:50:59 -0500
In-Reply-To: <474DC0F3.8070604@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> David Acker wrote:
>>> What is the status of this patch?
>>
>> Jeff merged it in netdev-2.6#upstream so it is queued for 2.6.25.
>>
>> However, we could consider pushing this patch to 2.6.24 since it's a 
>> valid fix.
>> Andrew has also been carrying this patch in -mm for a while and so 
>> have we over
>> here without issues.
>>
>> Jeff, what do you think?
> 
> IMO it's too late into 2.6.24-rc to push it.  It needs the additional 
> exposure that 2.6.25 merge window will give it.  Since we don't have 
> people actively complaining today, there is no need to stir the pot for 
> 2.6.24-rc.
This sounds good to me.  Thanks!
-Ack
