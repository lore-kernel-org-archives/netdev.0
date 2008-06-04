From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] SCTP: Move sctp_v4_dst_saddr out of loop
Date: Wed, 04 Jun 2008 12:38:17 -0700 (PDT)
Message-ID: <20080604.123817.78089516.davem@davemloft.net>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
	<1212603951-24932-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	guijianfeng@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48930
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762652AbYFDTiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:38:18 -0400
In-Reply-To: <1212603951-24932-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  4 Jun 2008 14:25:47 -0400

> There's no need to execute sctp_v4_dst_saddr() for each
> iteration, just move it out of loop.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.

