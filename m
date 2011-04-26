From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v5 3/5] sctp: Add socket option operation
 for Auto-ASCONF
Date: Tue, 26 Apr 2011 08:35:57 +0800
Message-ID: <4DB6136D.4000704@cn.fujitsu.com>
References: <0A966B15-C985-40AC-9402-CAE9BA7F2AC2@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51589 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752913Ab1DZAgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 20:36:11 -0400
In-Reply-To: <0A966B15-C985-40AC-9402-CAE9BA7F2AC2@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Michio

> This patch allows the application to operate Auto-ASCONF on/off behavior via setsockopt() and getsockopt().  

You should update your net-next tree first, and then
create patch base on the latest source code.

> +#define SCTP_AUTO_ASCONF       29

29 has been assigned to other socket option.

>  
>
