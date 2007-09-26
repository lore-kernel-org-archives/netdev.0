From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP PULL Request]: Bug fixes for 2.6.23
Date: Wed, 26 Sep 2007 09:02:47 -0400
Message-ID: <46FA5877.3070004@hp.com>
References: <46F8252D.3090803@hp.com> <20070925.225330.60538571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:47573 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbXIZNDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 09:03:15 -0400
In-Reply-To: <20070925.225330.60538571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 24 Sep 2007 16:59:25 -0400
> 
>> Can you please pull the following changes since commit a41d3015c11a4e864b95cb57f579f2d8f40cd41b:
> 
> I had to apply this by hand because:
> 
>>   David S. Miller (1):
>>         Revert "PCI: disable MSI by default on systems with Serverworks HT1000 chips"
> 
> You did this work on a very old tree of mine that I redid
> at one point.  This MSI changeset I yanked out of my net-2.6
> tree during a rebase, so if I pull I get the thing back
> which I definitely don't want :-)
> 
> Just to let you know what's happening and why I couldn't
> pull directly from your tree into mine.

Sorry, this was my fault.  I forgot the -f when I pushed out the changes.  That
should have updated the tree.

/me adds a + to the push line.

-vlad

