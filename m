From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter tables config problem
Date: Mon, 12 Feb 2007 21:30:02 +0100
Message-ID: <45D0CE4A.7050806@trash.net>
References: <20061222183312.f3cf3220.randy.dunlap@oracle.com> <20070212.122324.112265617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50070 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965348AbXBLUaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:30:05 -0500
In-Reply-To: <20070212.122324.112265617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Fri, 22 Dec 2006 18:33:12 -0800
> 
> I'm pretty sure we fixed that one already.  Randy do you have some
> objection to testing 2.6.20-final when discoving such bugs? :-)


Sorry for the confusion, we had an 8 months backlog of non-subscriber
posted mails and I released them all today. You can probably ignore
all mails on netfilter-devel you received today, I'll go over them
to look for anything important.

The hashlimit problem is fixed in 2.6.20 :)
