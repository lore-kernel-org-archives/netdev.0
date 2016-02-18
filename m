From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] et131x: check return value of dma_alloc_coherent
Date: Wed, 17 Feb 2016 23:32:30 -0500 (EST)
Message-ID: <20160217.233230.129787118424936826.davem@davemloft.net>
References: <1455589427-6882-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.einon@gmail.com, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424573AbcBREch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 23:32:37 -0500
In-Reply-To: <1455589427-6882-1-git-send-email-wuninsu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Insu Yun <wuninsu@gmail.com>
Date: Mon, 15 Feb 2016 21:23:47 -0500

> For error handling, dma_alloc_coherent's return value
> needs to be checked, not argument.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied, thanks.
