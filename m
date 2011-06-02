From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 4/6 v9] sctp: Add sysctl support for Auto-ASCONF.
Date: Thu, 02 Jun 2011 15:19:38 +0800
Message-ID: <4DE7398A.3050203@cn.fujitsu.com>
References: <B723DBE5-24B2-4F5D-873A-4AB68F7B032C@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53642 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932145Ab1FBHUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 03:20:40 -0400
In-Reply-To: <B723DBE5-24B2-4F5D-873A-4AB68F7B032C@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >From 6d5abc7fa954ffa8808f4dd78636984c0cd57ce8 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Tue, 26 Apr 2011 17:36:05 +0900
> Subject: [PATCH 4/6 v9] sctp: Add sysctl support for Auto-ASCONF.
>
> This patch allows the system administrator to change default
> Auto-ASCONF on/off behavior via an sysctl value.
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/sctp/sysctl.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>
>
Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

