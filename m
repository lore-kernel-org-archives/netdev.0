From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/3] dccp: Ack Vectors in circular buffer
 instead of array
Date: Thu, 11 Nov 2010 10:45:24 -0800 (PST)
Message-ID: <20101111.104524.48510509.davem@davemloft.net>
References: <ack_vector_circular_buffer_dccp>
	<1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755586Ab0KKSo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:44:59 -0500
In-Reply-To: <1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 07:07:30 +0100

>  Patch #1: cleans up the old interface to prepare for the improved one.
>  Patch #2: also tidies up the old interface, by separating the internals
>            of Ack Vectors from the option-parsing code.
>  Patch #3: Completes the implementation of a circular Ack Vector buffer.
> 
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> The set has been tested for 3 years, and is fully bisectable.

Pulled, thanks!
