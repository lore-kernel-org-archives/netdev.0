From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: delete extra semicolon blocking node
 deletion
Date: Mon, 14 Mar 2011 13:50:26 -0700 (PDT)
Message-ID: <20110314.135026.189708616.davem@davemloft.net>
References: <1300122682-13752-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43627
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab1CNUtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:49:49 -0400
In-Reply-To: <1300122682-13752-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 14 Mar 2011 13:11:22 -0400

> Remove bogus semicolon only recently introduced in 34e46258cb9f5
> that blocks cleanup of nodes for N>1 on shutdown.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> 
> Also available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-Mar14-2011

Pulled, thanks Paul.

We should probably change all text editors in the world to display
semi-colon characters large and flashing red when editing C code :)
