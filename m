From: David Miller <davem@davemloft.net>
Subject: README: networking GIT trees
Date: Sun, 07 Aug 2011 23:40:27 -0700 (PDT)
Message-ID: <20110807.234027.1850968504654724492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, sfr@canb.auug.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab1HHGm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 02:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net-next is now open up and all pending -next patches have been
integrated and pushed out.  Also, the plain 'net' tree has been
pulled into it.

However I am freezing driver/net in net-next so that Jeff can
have a few days to push his drivers/net reorganization GIT tree
to me.

Once Jeff's work is merged in, I do recognize that we will have
some merge hassles any time a net driver bug fix is merged into
the 'net' tree.  I will try to pre-emptively address this with
quick merges into net-next when possible.

This is just a heads up if one of these merge hassles propagates
into -next for some reason, they are expected and I will clean
them up as fast as possible.
