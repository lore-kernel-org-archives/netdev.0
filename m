From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH v1] sctp: kzalloc() error handling on deleting last address
Date: Sat, 11 Jun 2011 09:33:54 +0800
Message-ID: <4DF2C602.3000101@cn.fujitsu.com>
References: <42280E6C-8514-4C01-9B81-35DDE65BBE42@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62978 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758453Ab1FKBfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 21:35:24 -0400
In-Reply-To: <42280E6C-8514-4C01-9B81-35DDE65BBE42@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From be2da529aa45061e77ad96313175e141aaadc16a Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Fri, 10 Jun 2011 16:42:14 +0900
> Subject: [PATCH v1] sctp: kzalloc() error handling on deleting last address
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
>  net/sctp/socket.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
It is OK to me.

Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

