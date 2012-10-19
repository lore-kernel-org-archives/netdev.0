From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/21] treewide: Use consistent api style for
 address testing
Date: Fri, 19 Oct 2012 03:36:12 -0400 (EDT)
Message-ID: <20121019.033612.1675650655648502777.davem@davemloft.net>
References: <cover.1350618006.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab2JSHgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 03:36:14 -0400
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


CC list too large, so this didn't make it to any of the vger lists.

And therefore nobody on the vger lists saw Eric Dumazet's reply
either.

But anyways, like him I think this is useless churn and it's
largest side effect will be making backports harder.
