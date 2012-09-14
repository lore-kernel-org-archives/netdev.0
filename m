From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] ipconfig: Inform user if carrier is not ready
Date: Fri, 14 Sep 2012 15:42:27 -0400 (EDT)
Message-ID: <20120914.154227.677746835040890172.davem@davemloft.net>
References: <505380A0.7020407@gmail.com>
	<20120914.151724.505809965127351650.davem@davemloft.net>
	<505385E2.6050600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com
To: erwanaliasr1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354Ab2INTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 15:42:29 -0400
In-Reply-To: <505385E2.6050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Your email client is still corrupting this patch.

Turn off all transformations in your outgoing emails such as
text formatting and such.

In fact, email the patch to yourself, and make sure you can successfully
apply the result.

Also, you have formatted the comment improperly.

Don't format comments:

	/* Like
	   this.  */

but rather, format them:

	/* Like
	 * this.
	 */

You also didn't style the variable declaration and assignment properly,
there must be a space around the "=" sign, like this:

	unsigned int loops = 0;

Thanks.
