From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: netfilter tables config problem
Date: Mon, 12 Feb 2007 12:42:50 -0800
Message-ID: <20070212124250.65a96ac2.randy.dunlap@oracle.com>
References: <20061222183312.f3cf3220.randy.dunlap@oracle.com>
	<20070212.122324.112265617.davem@davemloft.net>
	<45D0CE4A.7050806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:18362 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965279AbXBLUxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:53:50 -0500
In-Reply-To: <45D0CE4A.7050806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Feb 2007 21:30:02 +0100 Patrick McHardy wrote:

> David Miller wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > Date: Fri, 22 Dec 2006 18:33:12 -0800
> > 
> > I'm pretty sure we fixed that one already.  Randy do you have some
> > objection to testing 2.6.20-final when discoving such bugs? :-)
> 
> 
> Sorry for the confusion, we had an 8 months backlog of non-subscriber
> posted mails and I released them all today. You can probably ignore
> all mails on netfilter-devel you received today, I'll go over them
> to look for anything important.
> 
> The hashlimit problem is fixed in 2.6.20 :)

Ack, yes, it builds cleanly now.

and thanks for the explanation.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
