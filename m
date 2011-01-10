From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/3] dccp: several sequence-number
 validation fixes
Date: Sun, 09 Jan 2011 16:17:33 -0800 (PST)
Message-ID: <20110109.161733.241928340.davem@davemloft.net>
References: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
	<1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343Ab1AJARB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 19:17:01 -0500
In-Reply-To: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri,  7 Jan 2011 12:35:27 +0100

> Hi Dave,
> 
> please find attached 3 bug fixes which recently came up on dccp@vger.
> 
>  Patch #1: fixes a bug which wrongly classified sequence-invalid packets. 
>  Patch #2: fixes a bug in updating the Greatest Sequence number Received (GSR).
>  Patch #3: fixes an inconsistency in setting the sequence window on 32/64 bit.
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Pulled, thanks a lot Gerrit.
