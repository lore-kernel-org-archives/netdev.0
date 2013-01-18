From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn/gigaset: off by one check leading to oops
Date: Fri, 18 Jan 2013 15:26:46 +0300
Message-ID: <20130118122646.GM4584@mwanda>
References: <20130117074405.GA26270@elgon.mountain>
 <50F93D78.5010903@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20135 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3ARM1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 07:27:12 -0500
Content-Disposition: inline
In-Reply-To: <50F93D78.5010903@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 01:18:00PM +0100, Tilman Schmidt wrote:
> I'll prepare a patch of my own, citing you as reporter, if that's
> ok with you.
> 

That sounds great.

regards,
dan carpenter
