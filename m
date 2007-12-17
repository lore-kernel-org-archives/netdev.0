From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] net/netlabel/: Spelling fixes
Date: Mon, 17 Dec 2007 14:49:23 -0500
Message-ID: <200712171449.24007.paul.moore@hp.com>
References: <1197920439-5455-29-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:45629 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935069AbXLQTtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:49:52 -0500
In-Reply-To: <1197920439-5455-29-git-send-email-joe@perches.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 December 2007 2:40:35 pm Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks Joe.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_mgmt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
> index 5648337..9c41464 100644
> --- a/net/netlabel/netlabel_mgmt.c
> +++ b/net/netlabel/netlabel_mgmt.c
> @@ -71,7 +71,7 @@ static const struct nla_policy
> netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = { };
>
>  /*
> - * NetLabel Misc Managment Functions
> + * NetLabel Misc Management Functions
>   */
>
>  /**



-- 
paul moore
linux security @ hp
