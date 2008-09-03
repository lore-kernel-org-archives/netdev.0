From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: tipc on sparc32
Date: Tue, 2 Sep 2008 23:54:43 -0700
Message-ID: <20080902235443.130f7b36.akpm@linux-foundation.org>
References: <20080902224059.70a182ba.akpm@linux-foundation.org>
	<20080902.231201.184658566.davem@davemloft.net>
	<20080902.232627.209816179.davem@davemloft.net>
	<20080902.234020.211119869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37402 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752732AbYICGzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 02:55:22 -0400
In-Reply-To: <20080902.234020.211119869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Sep 2008 23:40:20 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> This just regexp replaces "struct node*" to "struct tipc_node*"
> to avoid this and any future similar problems.

Looks good, thanks.  The end result is (IMO) better-looking
code.  Successful compilation is a side-benefit ;)
