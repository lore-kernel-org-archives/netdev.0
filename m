From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net/mlx4_en: fix error return code in
 mlx4_en_get_qp()
Date: Tue, 07 Jan 2014 15:43:28 -0500 (EST)
Message-ID: <20140107.154328.116165277036485786.davem@davemloft.net>
References: <CAPgLHd9HUbNsD-rKi3CSVc6gG7TAn54mDJT2WcVu4K9kJ9PuYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, ogerlitz@mellanox.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaAGUn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:43:29 -0500
In-Reply-To: <CAPgLHd9HUbNsD-rKi3CSVc6gG7TAn54mDJT2WcVu4K9kJ9PuYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 7 Jan 2014 16:56:07 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0.
> 
> Fixes: 837052d0ccc5 ('net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Looks good, applied, thanks.
