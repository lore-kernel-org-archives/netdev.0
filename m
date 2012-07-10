From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/16] tcp: Move timestamps from inetpeer to metrics
 cache.
Date: Tue, 10 Jul 2012 09:17:44 -0700 (PDT)
Message-ID: <20120710.091744.730481765624036830.davem@davemloft.net>
References: <20120710.080726.1369956163447074824.davem@davemloft.net>
	<CAF1ivSZ--OKqu-PgTf82Rho4N8tUn+HCaDuh5V4p89KusHauWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034Ab2GJQRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 12:17:46 -0400
In-Reply-To: <CAF1ivSZ--OKqu-PgTf82Rho4N8tUn+HCaDuh5V4p89KusHauWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Wed, 11 Jul 2012 00:14:50 +0800

> A trivial thing when "git am" this patch.
> 
> ERROR: trailing whitespace
> #315: FILE: net/ipv4/tcp_metrics.c:595:
> +^I}^I^I$

Thanks, I'll fix that up.
