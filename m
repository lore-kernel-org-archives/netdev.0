From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bnx2x: Enhancements patch series
Date: Wed, 24 Apr 2013 16:35:29 -0400 (EDT)
Message-ID: <20130424.163529.326546938987869912.davem@davemloft.net>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757960Ab3DXUfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 16:35:32 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 24 Apr 2013 14:44:57 +0300

> This patch series contains several enhancements, as well as small fixes:
> 
>   - Patch [1/5] - Prevent a theoretical problem in our GRO implementation.
> 
>   - Patch [2/5] - Support Rx/Tx pause control configuration in autoneg.
> 
>   - Patch [3/5] - Enhance support for VF's MAC setting and removal.
> 
>   - Patch [4/5] - Fix a small memory leak between bnx2x and cnic.
> 
>   - Patch [5/5] - Allow bnx2x to recover after a second slot reset.
> 
> Please consider applying these patches to `net-next'.

Applied, but please give a more detailed and verbose top-level description
of what is happening in the series in your "0/N" emails.

You're just regurgitating the git shortlog output, anybody can see that
in the repo itself.  The idea of the "0/N" message body is to explain the
series from a high level.
