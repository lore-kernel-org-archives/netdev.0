From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/6 v9] sctp: Add ADD/DEL ASCONF handling at the receiver.
Date: Thu, 02 Jun 2011 15:18:12 +0800
Message-ID: <4DE73934.3050209@cn.fujitsu.com>
References: <506FB213-6C73-4F00-95B2-E20976F2064E@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50223 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757514Ab1FBHS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 03:18:57 -0400
In-Reply-To: <506FB213-6C73-4F00-95B2-E20976F2064E@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> >From fb3b20d29f89c1570d44df7fdc20fe0ed12a71f0 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Tue, 26 Apr 2011 17:37:02 +0900
> Subject: [PATCH 1/6 v9] sctp: Add ADD/DEL ASCONF handling at the receiver.
>
> This patch fixes the problem that the original code cannot delete
> the remote address where the corresponding transport is currently
> directed, even when the ASCONF is sent from the other address (this
> situation happens when the single-homed sender transmits  ASCONF
> with ADD and DEL.)
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>
Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

