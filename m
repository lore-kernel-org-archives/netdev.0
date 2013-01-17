From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix ipv6_prefix_equal64_half mask
 conversion
Date: Wed, 16 Jan 2013 22:50:19 -0500 (EST)
Message-ID: <20130116.225019.1532550974298014656.davem@davemloft.net>
References: <1358371817-15378-1-git-send-email-fabio.baltieri@linaro.org>
	<20130116.163729.1934084260354327196.davem@davemloft.net>
	<50F771BE.7070309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758576Ab3AQDuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:50:22 -0500
In-Reply-To: <50F771BE.7070309@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 17 Jan 2013 12:36:30 +0900

> I'm not seeing this in net-next so far, though I can see my
> patch for ip6_flow_hdr() which you "applied" later.
> Do I miss something?

It's sitting in my local GIT tree on a machine I use during the day at
an office, I forgot to push some changes out before I headed home.

I'll fix it up tomorrow.
