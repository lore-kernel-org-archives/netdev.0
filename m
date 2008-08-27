From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/6]: DCCP code updates
Date: Wed, 27 Aug 2008 05:10:09 -0700 (PDT)
Message-ID: <20080827.051009.172328596.davem@davemloft.net>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
	<1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753927AbYH0MKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 08:10:14 -0400
In-Reply-To: <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Aug 2008 07:35:19 +0200

> can you please consider pulling this set - consisting mainly of code updates
> with regard to the RFC, and a few other minor updates.
> 
> Patch #1: Update to always respond with Reset to option errors, as per the RFC. 
> Patch #2: Another update with regard to RFC 4340 - ignore nonsensical options.
> Patch #3: Third update with regard to the RFC - fill in the Reset-Data fields.
> Patch #4: Update to flush the write queue when disconnecting.
> Patch #5: Allow runtime toggling of the `debug' switches via sysfs.
> Patch #6: Replaces an unnecessary CCID-3 BUG_ON with a (better) condition.
> 
> This code has been tested and been in the DCCP test tree for some while. 
> 
> Applied to a fresh (today) copy of net-next-2.6, the patches can be pulled from
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	[subtree `master']

Pulled, thanks Gerrit.
