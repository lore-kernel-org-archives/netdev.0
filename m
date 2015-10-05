From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vrf: fix a kernel warning
Date: Mon, 05 Oct 2015 06:36:36 -0700 (PDT)
Message-ID: <20151005.063636.1350059957507396458.davem@davemloft.net>
References: <1443738068-30750-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbJENU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:20:56 -0400
In-Reply-To: <1443738068-30750-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  1 Oct 2015 15:21:08 -0700

> This fixes:
 ...
> Fixes: 93a7e7e837af ("net: Remove the now unused vrf_ptr")
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
