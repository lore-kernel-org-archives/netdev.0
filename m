From: David Miller <davem@davemloft.net>
Subject: GIT tree names 's/-2.6//'
Date: Thu, 21 Jul 2011 20:26:43 -0700 (PDT)
Message-ID: <20110721.202643.1084293436022974836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab1GVD2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 23:28:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The GIT trees for network development will now just be
called just plain "net.git" and "net-next.git"

I have symlinks installed so the old net-2.6.git and
net-next-2.6.git paths still work, but eventually I'd
like to remove them.

It's pretty easy to change the URL in .git/config of any
trees you have checked out, or in any scripts you use to
fetch from my trees.

Thanks.
