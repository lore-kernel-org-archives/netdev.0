From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ravb: Remove rx buffer ALIGN
Date: Tue, 03 May 2016 12:45:32 -0400 (EDT)
Message-ID: <20160503.124532.1725999245771500071.davem@davemloft.net>
References: <1462115991-27241-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635AbcECQpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:45:34 -0400
In-Reply-To: <1462115991-27241-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Mon,  2 May 2016 00:19:51 +0900

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> Aligning the reception data size is not required.
> 
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Tested-by: Simon Horman <horms+renesas@verge.net.au>

Applied, thanks.
