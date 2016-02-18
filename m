From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: correctly crypto_alloc_hash return check
Date: Wed, 17 Feb 2016 22:23:24 -0500 (EST)
Message-ID: <20160217.222324.221201149229609628.davem@davemloft.net>
References: <1455589833-7571-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423890AbcBRDX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:23:28 -0500
In-Reply-To: <1455589833-7571-1-git-send-email-wuninsu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Insu Yun <wuninsu@gmail.com>
Date: Mon, 15 Feb 2016 21:30:33 -0500

> crypto_alloc_hash never returns NULL
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied, thanks.
