From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH for/net-next 3/8] net/mlx5: Mellanox Connect-IB, core driver part 3/3
Date: Tue, 2 Jul 2013 11:06:50 +0300
Message-ID: <201307021106.51349.jackm@dev.mellanox.co.il>
References: <1372256537-21328-4-git-send-email-ogerlitz@mellanox.com> <201307011444.55361.jackm@dev.mellanox.co.il> <20130701.121854.1781783893978810119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eli@dev.mellanox.co.il, moshel@mellanox.com, eli@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:52330 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab3GBIFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:05:11 -0400
Received: by mail-we0-f170.google.com with SMTP id w57so4110668wes.29
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 01:05:09 -0700 (PDT)
In-Reply-To: <20130701.121854.1781783893978810119.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 01 July 2013 22:18, David Miller wrote:
> Actually, you should adjust both decrements to read "i--".
> 
OK, will do it.

-Jack
