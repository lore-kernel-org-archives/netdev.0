From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 6/6 v9] sctp: Add ASCONF operation on the single-homed
 host
Date: Thu, 02 Jun 2011 15:20:34 +0800
Message-ID: <4DE739C2.4000306@cn.fujitsu.com>
References: <99BEF1C4-C638-4007-A538-E43B1463F564@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58736 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932145Ab1FBHVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 03:21:17 -0400
In-Reply-To: <99BEF1C4-C638-4007-A538-E43B1463F564@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >From 907306fafe1ebdde2ad42aefbc6e45821b448cbf Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Tue, 26 Apr 2011 20:19:36 +0900
> Subject: [PATCH 6/6 v9] sctp: Add ASCONF operation on the single-homed host
>
> In this case, the SCTP association transmits an ASCONF packet
> including addition of the new IP address and deletion of the old
> address.  This patch implements this functionality.
> In this case, the ASCONF chunk is added to the beginning of the
> queue, because the other chunks cannot be transmitted in this state.
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  

Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

