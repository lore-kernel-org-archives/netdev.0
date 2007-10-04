From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 rebased
Date: Wed, 03 Oct 2007 22:07:16 -0700 (PDT)
Message-ID: <20071003.220716.71090595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751286AbXJDFHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 01:07:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Available as usual at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git

I resolved the SCTP and network driver conflicts that come standard
with a rebase to Linus's current tree.

We're up to 700 changesets and an 8.7 MB patch, w00t!

I've been using it for an hour or so on my workstation so something
works.  It also passes an allmodconfig build on sparc64.

Either later tonight or some time tomorrow I'll start hitting the
patch backlog in my inbox.

Thanks.
