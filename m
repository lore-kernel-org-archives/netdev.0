From: David Miller <davem@davemloft.net>
Subject: Re: [SCTP PULL Request]: Bug fixes for 2.6.23
Date: Tue, 25 Sep 2007 22:53:30 -0700 (PDT)
Message-ID: <20070925.225330.60538571.davem@davemloft.net>
References: <46F8252D.3090803@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751387AbXIZFxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 01:53:30 -0400
In-Reply-To: <46F8252D.3090803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 24 Sep 2007 16:59:25 -0400

> Can you please pull the following changes since commit a41d3015c11a4e864b95cb57f579f2d8f40cd41b:

I had to apply this by hand because:

>   David S. Miller (1):
>         Revert "PCI: disable MSI by default on systems with Serverworks HT1000 chips"

You did this work on a very old tree of mine that I redid
at one point.  This MSI changeset I yanked out of my net-2.6
tree during a rebase, so if I pull I get the thing back
which I definitely don't want :-)

Just to let you know what's happening and why I couldn't
pull directly from your tree into mine.
