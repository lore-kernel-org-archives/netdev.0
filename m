From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 [PATCH 0/2] udp/dccp: MSG_TRUNC
Date: Fri, 12 Feb 2010 16:51:35 -0800 (PST)
Message-ID: <20100212.165135.76878917.davem@davemloft.net>
References: <udp_dccp_msg_trunc>
	<1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757320Ab0BMAvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 19:51:22 -0500
In-Reply-To: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Feb 2010 07:26:17 +0100

> I have here two datagram-API patches, both submitted for net-2.6:

These are not appropriate for net-2.6, so I will apply them to
net-next-2.6

> Patch #1: Resolves missing MSG_TRUNC support. Since DCCP is datagram-based,
>           the user-space API is broken/incomplete without.
> 
> Patch #2: UDP recvmsg() cleanup, remove redundant variable. 	  


Applied, thanks.
