From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 3/6 v9] sctp: Add Auto-ASCONF support (core).
Date: Thu, 02 Jun 2011 15:19:13 +0800
Message-ID: <4DE73971.3020908@cn.fujitsu.com>
References: <0750E26B-3F0C-4280-AC8D-DECFDA5C48E1@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52479 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756666Ab1FBHT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 03:19:57 -0400
In-Reply-To: <0750E26B-3F0C-4280-AC8D-DECFDA5C48E1@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >From fb6a7bb57810aff5ea542a24119b857a6843ac88 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Tue, 26 Apr 2011 19:32:51 +0900
> Subject: [PATCH 3/6 v9] sctp: Add Auto-ASCONF support (core).
>
> SCTP reconfigure the IP addresses in the association by using
> ASCONF chunks as mentioned in RFC5061.  For example, we can
> start to use the newly configured IP address in the existing
> association.  This patch implements automatic ASCONF operation
> in the SCTP stack with address events in the host computer,
> which is called auto_asconf.
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  

Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

