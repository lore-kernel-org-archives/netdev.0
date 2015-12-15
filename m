From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] pptp: verify sockaddr_len in pptp_bind() and
 pptp_connect()
Date: Tue, 15 Dec 2015 00:30:22 -0500 (EST)
Message-ID: <20151215.003022.2241775391037074869.davem@davemloft.net>
References: <1450129716-32422-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbLOFaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 00:30:24 -0500
In-Reply-To: <1450129716-32422-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 14 Dec 2015 13:48:36 -0800

> Reported-by: Dmitry Vyukov <dvyukov@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
