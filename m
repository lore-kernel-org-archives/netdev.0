From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 net-next] veth: add netpoll support
Date: Wed, 25 Jun 2014 16:35:56 -0700 (PDT)
Message-ID: <20140625.163556.2080764660174492587.davem@davemloft.net>
References: <1403562962-17502-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.priebe@profihost.ag,
	nhorman@tuxdriver.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbaFYXf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:35:57 -0400
In-Reply-To: <1403562962-17502-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Jun 2014 15:36:02 -0700

> It is trivial to add netpoll support to veth, since
> it is not a stacked device, we don't need to setup and
> clean up netpoll.
> 
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
