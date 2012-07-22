From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] tcp: use seqlock for all cached tcp_metrics
Date: Sun, 22 Jul 2012 14:50:48 -0700 (PDT)
Message-ID: <20120722.145048.1347616922673277010.davem@davemloft.net>
References: <1342950268-2380-1-git-send-email-ja@ssi.bg>
	<20120722.123246.864281319907290494.davem@davemloft.net>
	<alpine.LFD.2.00.1207222314230.2458@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab2GVVu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 17:50:59 -0400
In-Reply-To: <alpine.LFD.2.00.1207222314230.2458@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 22 Jul 2012 23:34:38 +0300 (EEST)

> So, I can just send patch (or 2) for the tcpm_stamp and
> tcp_tw_remember_stamp problems, now or after 2 weeks?

You can send it now.
