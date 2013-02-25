From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-02-25
Date: Mon, 25 Feb 2013 15:46:52 -0500 (EST)
Message-ID: <20130225.154652.1215363481985361759.davem@davemloft.net>
References: <20130225201748.GC6455@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3BYUqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:46:54 -0500
In-Reply-To: <20130225201748.GC6455@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 25 Feb 2013 15:17:49 -0500

> This is a batch of fixes intended for the 3.9 stream...
> 
> Avinash Patil gives us a mwifiex fix to prevent a system freeze when
> that driver is unloaded.
> 
> Daniel Drake brings a patch to avoid dropping the carrier flag across a
> suspend.  This prevents improper packet drops.
> 
> Wei Yongjun delivers a brcmfmac for a lock leak on an error path.
> 
> Please let me know if there are problems!

Pulled, thanks John.
