From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next] GRE over IPv6
Date: Fri, 10 Aug 2012 03:37:37 -0700 (PDT)
Message-ID: <20120810.033737.1090425735537554996.davem@davemloft.net>
References: <2771535.Z5nRARPP6B@dima>
	<20120810.020832.1316928513286464500.davem@davemloft.net>
	<51746494.4Ihy4IeQnj@dima>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab2HJKhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 06:37:40 -0400
In-Reply-To: <51746494.4Ihy4IeQnj@dima>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kozlov Dmitry <xeb@mail.ru>
Date: Fri, 10 Aug 2012 13:16 +0400

> But I resend patch as attachment, is it invalid too ?

It doesn't have the mail mangling errors, but it has another one:

+ git apply --check --whitespace=error-all RESEND-net-next-v2-GRE-over-IPv6.patch
RESEND-net-next-v2-GRE-over-IPv6.patch:1999: new blank line at EOF.
+
fatal: 1 line adds whitespace errors.
