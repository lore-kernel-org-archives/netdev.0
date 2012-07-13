From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] tipc: Use pr_fmt
Date: Fri, 13 Jul 2012 11:45:44 -0400
Message-ID: <20120713154544.GA31280@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
 <1342115481.13046.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, <ying.xue@windriver.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51743 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899Ab2GMPpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 11:45:53 -0400
Content-Disposition: inline
In-Reply-To: <1342115481.13046.5.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH net-next] tipc: Use pr_fmt] On 12/07/2012 (Thu 10:51) Joe Perches wrote:

[...]

> 
> How about extending this to use the more common pr_fmt prefix?

We can probably do that.  I'll incorporate that into the 3/8 patch,
rather than have two similar patches in the series, with the 2nd just
going in and touching all the same lines a second time.

Thanks,
Paul.
