From: David Miller <davem@davemloft.net>
Subject: macvlan/macvtap patch in patchwork
Date: Tue, 27 Sep 2011 15:14:15 -0400 (EDT)
Message-ID: <20110927.151415.1749891588648068894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	krkumar2@in.ibm.com, david.ward@ll.mit.edu
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab1I0TQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Could you guys please review:

	http://patchwork.ozlabs.org/patch/115273/

My gut instinct is that the current behavior is intentional, but since
the patch submitter didn't describe exactly what the undesirable
behavior is it's hard to tell what the patch is actually fixing.

Thanks.
