From: Alex <d77190@mail.ru>
Subject: Re: Bug 75571
Date: Mon, 02 Jun 2014 17:32:28 +0700
Message-ID: <1401705148.1775.29.camel@anpws>
References: <1401085231.1775.9.camel@anpws> <20140601144341.GA4382@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnat3.880.ru ([194.8.85.227]:29494 "EHLO stk-gw0.880.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754069AbaFBKcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 06:32:20 -0400
Received: from [198.18.184.34] (unknown [198.18.184.34])
	by stk-gw0.880.ru (Postfix) with ESMTP id C095FCC042
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 17:32:16 +0700 (NOVT)
In-Reply-To: <20140601144341.GA4382@lianli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Perhaps you would like to try version 3.15-rc7 of the kernel and
> see if you can reproduce the bug?
I cannot reproduce bug on 3.15-rc7.

In changelog of 3.15-rc7 I see: "net_sched: fix an oops in tcindex
filter."
Is there any backport of this patch to 3.2 to check if it fixes problem?
