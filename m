From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: introduce helper macro for_each_cmsghdr
Date: Wed, 10 Dec 2014 22:42:30 -0500 (EST)
Message-ID: <20141210.224230.1611636286785782770.davem@davemloft.net>
References: <54890DDC.3040402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
To: guz.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933557AbaLKDmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 22:42:35 -0500
In-Reply-To: <54890DDC.3040402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Date: Thu, 11 Dec 2014 11:22:04 +0800

> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
> cmsghdr from msghdr, just cleanup.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> ---
> v3:
>  -drop the changes about user-land programs as David suggested.
> v2:
>  -use the lower-case macro name as Joe suggested.

Applied, thanks.
