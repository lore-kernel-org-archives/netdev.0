From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v6 4/5] sctp: Add ADD/DEL ASCONF handling
 at the receiver
Date: Tue, 26 Apr 2011 13:31:51 +0800
Message-ID: <4DB658C7.7030003@cn.fujitsu.com>
References: <BECB6CDC-BC4F-4BC1-B67D-B9F3F02E8D87@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57285 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752531Ab1DZFcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:32:06 -0400
In-Reply-To: <BECB6CDC-BC4F-4BC1-B67D-B9F3F02E8D87@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This patch fixes the problem that the original code cannot delete the remote address where the corresponding transport is currently directed, even when the ASCONF is sent from the other address (this situation happens when the single-homed sender transmits  ASCONF with ADD and DEL.)  
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
>
Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

