From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 15/15] tipc: remove old ASCII netlink API
Date: Fri, 03 Oct 2014 16:50:38 -0700 (PDT)
Message-ID: <20141003.165038.2121547250200790300.davem@davemloft.net>
References: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
	<1412261921-28510-16-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbaJCXsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 19:48:39 -0400
In-Reply-To: <1412261921-28510-16-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Thu, 2 Oct 2014 16:58:41 +0200

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> The API has been deprecated along with its user-space tool
> "tipc-config". Users shall use the new kernel netlink API already in
> place along with the new user space tool "tipc" that's part of the
> tipc-utils package.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Sorry, no matter what your circumstances, you cannot just break
binaries that might be out there.

The rest of this patch series is fine, but I'm really not going
to even entertain applying this one, sorry.
