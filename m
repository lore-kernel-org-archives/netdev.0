From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rtnetlink: remove dead code
Date: Wed, 02 Mar 2016 15:02:48 -0500 (EST)
Message-ID: <20160302.150248.855682703255530961.davem@davemloft.net>
References: <1456763798-629-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@mellanox.com, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	eranbe@mellanox.com, tgraf@suug.ch, hubert.sokolowski@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.engestrom@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbcCBUCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:02:50 -0500
In-Reply-To: <1456763798-629-1-git-send-email-eric.engestrom@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Engestrom <eric.engestrom@imgtec.com>
Date: Mon, 29 Feb 2016 16:36:38 +0000

> 3b766cd832328fcb87db3507e7b98cf42f21689d ("net/core: Add reading VF
> statistics through the PF netdevice") added that variable but it's never
> been used.
> 
> Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>

Applied.
